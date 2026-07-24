public class Bees {
    public static C leak;
    public static C leak1;
    public static C leak2;
    public static void process(C c) {
        leak1 = new C();
        int limit = (int)(System.currentTimeMillis() % 20);
        if (limit < 0) limit = -limit;
        int y = 0, z = 1, w = 2, q = 3, r = 4, s = 5, t = 6;
        for (int i = 0; i < limit; i++) {
            for (int j = 0; j < limit; j++) {
                if ((limit + i) % 2 == 0) {
                    y += i; z *= (y+1); w ^= (z+limit); q -= (w*i); r += (q^j); s -= (r*z); t += (s*w);
                } else {
                    y -= j; z ^= (y-1); w *= (z-limit); q += (w/(i+1)); r -= (q^j); s += (r*z); t -= (s*w);
                }
            }
        }
        switch(limit) {
            case 101: y++; break;
            case 102: z++; break;
            case 103: w++; break;
            case 104: q++; break;
            case 105: r++; break;
            case 106: s++; break;
            case 107: t++; break;
            case 108: y--; break;
            case 109: z--; break;
            case 110: w--; break;
        }
        if (y == 999999) System.out.println(y + z + w + q + r + s + t);
        leak1 = c; // Escaping
    }
}
