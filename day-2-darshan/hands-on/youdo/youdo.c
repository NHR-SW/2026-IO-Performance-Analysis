/*
 * youdo.c - minimal MPI application with an I/O bottleneck.
 *
 * Every rank produces one block of data per time step. All blocks go into
 * one output file, block (step, rank) at offset (step * nprocs + rank) * BLOCK.
 *
 * Run it under Darshan, find out who does the I/O, then fix the two lines
 * marked HANDS-ON below.
 *
 * Usage: mpirun -np <N> ./youdo <output file>
 */
#include <mpi.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BLOCK_DOUBLES (128 * 1024) /* 1 MiB per rank and step */
#define BLOCK_BYTES   (BLOCK_DOUBLES * sizeof(double))
#define NSTEPS        8

static void write_block(int fd, const double *buf, off_t off, int writer_rank)
{
    if (pwrite(fd, buf, BLOCK_BYTES, off) != (ssize_t)BLOCK_BYTES) {
        fprintf(stderr, "rank %d: pwrite failed (did you change both TODO lines?)\n",
                writer_rank);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
}

static void __attribute__((unused))
write_all_from_root(int fd, const double *block, int step, int rank, int nprocs)
{
    double *all = NULL;

    if (rank == 0)
        all = malloc((size_t)nprocs * BLOCK_BYTES);

    MPI_Gather(block, BLOCK_DOUBLES, MPI_DOUBLE,
               all, BLOCK_DOUBLES, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        for (int r = 0; r < nprocs; r++) {
            off_t off = ((off_t)step * nprocs + r) * (off_t)BLOCK_BYTES;
            write_block(fd, all + (size_t)r * BLOCK_DOUBLES, off, rank);
        }
        free(all);
    }
}

static void __attribute__((unused))
write_own_block(int fd, const double *block, int step, int rank, int nprocs)
{
    off_t off = ((off_t)step + rank) * (off_t)BLOCK_BYTES;
    write_block(fd, block, off, rank);
}

int main(int argc, char *argv[])
{
    int rank, nprocs, fd = -1;
    double *block, t0, t_io;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    if (argc != 2) {
        if (rank == 0)
            fprintf(stderr, "usage: %s <output file>\n", argv[0]);
        MPI_Finalize();
        return 1;
    }

    block = malloc(BLOCK_BYTES);

    // TODO 1: who opens the output file?
    if (rank == 0)
        fd = open(argv[1], O_CREAT | O_WRONLY, 0644);
    MPI_Barrier(MPI_COMM_WORLD);

    t0 = MPI_Wtime();
    for (int step = 0; step < NSTEPS; step++) {
        /* "compute": fill this rank's block for this step */
        for (size_t i = 0; i < BLOCK_DOUBLES; i++)
            block[i] = rank + step * 0.001 + i * 1e-9;

        // TODO 2: who writes the data?
        write_all_from_root(fd, block, step, rank, nprocs);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    t_io = MPI_Wtime() - t0;

    if (fd >= 0)
        close(fd);
    if (rank == 0)
        printf("%d ranks wrote %d MiB in %.2f s\n", nprocs,
               (int)((size_t)nprocs * NSTEPS * BLOCK_BYTES >> 20), t_io);

    free(block);
    MPI_Finalize();
    return 0;
}

