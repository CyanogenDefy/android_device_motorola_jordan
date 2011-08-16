#include <stdio.h>

main()
{
	int c, r, g, b;
	int n = 0;
	while ((c = getchar()) != EOF) {
		switch (n++ % 3) {
			case 0: r = c; break;
			case 1: g = c; break;
			case 2: b = c;
					c = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3);
					putchar(c & 0xff);
					putchar((c>>8) & 0xff);
					break;
		}
	}
	if (n % 3)
		fprintf(stderr, "incomplete data\n");
}
