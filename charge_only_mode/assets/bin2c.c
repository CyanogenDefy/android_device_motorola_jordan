/*
 * Unloved program to convert a binary on stdin to a C include on stdout
 *
 * Jan 1999 Matt Mackall <mpm@selenic.com>
 *
 * This software may be used and distributed according to the terms
 * of the GNU General Public License, incorporated herein by reference.
 */

#include <stdio.h>

int main(int argc, char *argv[])
{
	int ch, total=0;
	int convert = 0;

	if ((argc > 1) && !strcmp(argv[1], "rgb24to16")) {
		convert = 1;
		argc--;
		argv++;
	}

	if (argc == 4)
		printf("static const unsigned char %s_bits[] = {\n", argv[1]);

	do {
		while ((ch = getchar()) != EOF)
		{
			if (convert) {
				static int r, g, b, counter;
				switch (counter++ % 3) {
					case 0: r = ch; break;
					case 1: g = ch; break;
					case 2: b = ch;
							printf("0x%04x, ",	((r >> 3) << 11) | 
												((g >> 2) << 5) | 
												(b >> 3));
							total += 2;
							break;
				}
			} else {
				printf("0x%02x,", ch);
				total++;
			}

			if (total % 16 == 0)
				break;
		}
		printf("\n");
	} while (ch != EOF);

	if (argc == 4)
		printf("};\n\nstruct asset %s = {\n\t%s, %s, %s_bits, sizeof(%s_bits) - 1, NULL };\n",
				argv[1], argv[2], argv[3], argv[1], argv[1]);

	return 0;
}
