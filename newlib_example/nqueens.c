/* Solve the n queens problem */

#include <stdio.h>
#include <stdlib.h>

#define MAX_N 8

long tries      = 0;
int  solutions  = 0;
int  n          = 0;
int  nsq        = 0;

/* display the board */
void print_board(int board[MAX_N*MAX_N])
{
  int i;

  printf("+");
  for (i = 0; i < n ; i++)
    printf("---");
  printf("+\n");

  for (i = 0; i < nsq ; i++) {
    if ((i % n) == 0)
      printf("|");
    if (board[i])
      printf(" Q ");
    else
      printf(" . ");
    if (((i+1) % n) == 0)
      printf("|\n");
  }

  printf("+");
  for (i = 0; i < n ; i++)
    printf("---");
  printf("+\n");
}

/* find position of a piece */
int piece(int n, int board[MAX_N*MAX_N])
{
  int i;
  static int cache[MAX_N+1]; /* get some savings by caching last position */

  /* first try the cache */
  if (board[cache[n]] == n)
    return cache[n];

  for (i = 0 ; i < nsq ; i++)
    if (board[i] == n) {
      cache[n] = i; /* cache it for next time */
      return i;
    }
  return -1;
}

/* see if board is a solution */
void check_board(int board[MAX_N*MAX_N])
{
  int i, p, r, c, j;

  /* loop over all pieces */
  for (i = 1 ; i <= n ; i++) {
      p = piece(i, board);

    /* not a solution if piece in same row */
    r = p / n;
    for (c = 0 ; c < n ; c++) {
      if (board[r*n+c] != 0 && board[r*n+c] != i)
	return;
    }

    /* not a solution if piece in same column */
    c = p % n;
    for (r = 0 ; r < n ; r++) {
      if (board[r*n+c] != 0 && board[r*n+c] != i)
	return;
    }

    /* not a solution if piece in same \ diagonal */
    for (j = -n ; j < n ; j++) {
      r = p / n + j;
      c = p % n + j;
      if ((r >= 0) && (r < n) && (c >= 0) && (c < n) &&
	  (board[r*n+c] != 0) && (board[r*n+c] != i))
	return;
    }
    /* not a solution if piece in same / diagonal */
    for (j = -n ; j < n ; j++) {
      r = p / n + j;
      c = p % n - j;
      if ((r >= 0) && (r < n) && (c >= 0) && (c < n) &&
	  (board[r*n+c] != 0) && (board[r*n+c] != i))
	return;
    }
  }
  solutions++;
  print_board(board);
}

/* move piece p to next position */
int next_pos(int p, int board[MAX_N*MAX_N])
{
  int i, t;

  if (p < 1)
    return 0;

  i = piece(p, board);

  if (i < nsq-n+p-1) {
    board[i] = 0;
    board[i+1] = p;
    return 1;
  } else {
    t = next_pos(p-1, board);
    board[i] = 0;
    board[piece(p-1, board)+1] = p;
    return t;
  }
}

/* generate the next possible solution */
int next_board(int board[MAX_N*MAX_N])
{
  return next_pos(n, board);
}


int main(void)
{
  int board[MAX_N*MAX_N];
  int i;
  char buff[10];

  printf("What size board? ");
  fgets(buff, sizeof(buff) - 1, stdin);
  n = atoi(buff);

  solutions = 0;
  nsq = n*n;           /* save n^2 to avoid calculating it again */

  printf("Solving n queens problem for n = %d\n", n);

  /* clear the board */
  for (i = 0 ; i < nsq ; i++)
    board[i] = 0;

  /* initially place the queens */
  for (i = 0 ; i < n ; i++)
    board[i] = i+1;

  do {
    tries++;
    check_board(board);
  } while (next_board(board));

  printf("Found %d solutions after %ld tries.\n", solutions, tries);

  return 0;
}
