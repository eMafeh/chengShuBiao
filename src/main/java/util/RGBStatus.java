package util;

import java.awt.*;

import static java.lang.Math.abs;
import static java.lang.Math.pow;

public class RGBStatus {
    //取色切面
    double[] d1 = {1, 2, 0};
    double[] d2 = {0, 0.6, 0.8};
    double[] o = MatrixUtil.fix(new double[]{1, 1, 1});

    public RGBStatus(final double[] d1, final double[] d2, final double[] o) {
        this.d1 = d1;
        this.d2 = d2;
        this.o = o;
    }

    public Color getColor(int x, int y) {
        int r = (int) (x * d1[0] + y * d2[0] + o[0]);
        int g = (int) (x * d1[1] + y * d2[1] + o[1]);
        int b = (int) (x * d1[2] + y * d2[2] + o[2]);
        return new Color(to(r), to(g), to(b));
    }

    public Color getColorMix(int x, int y) {
        int r = (int) (x * d1[0] + y * d2[0] + mixd(y, x, 1.0 / 2) * o[0]);
        int g = (int) (x * d1[1] + y * d2[1] + mixd(x, y, 1.0 / 3) * o[1]);
        int b = (int) (x * d1[2] + y * d2[2] + mix(y, x, 2) * o[2]);
        return new Color(to(r), to(g), to(b));
    }

    private double mix(final int a, final int b, final int i) {
        return pow(pow(a, i) % pow(b, i), 1.0 / i);
    }

    private int to(final int a) {
        int abs = abs(a);
        int i = abs % 512;
        return i >= 256 ? 511 - i : i;
    }

    private double mixd(final int a, final int b, final double i) {
        return pow(a, i) % pow(b, i);
    }

    private static double[][] MATRIX = MatrixUtil.doc(0.01, new double[]{-3, 4, 5});

    public void change() {
        d1 = MatrixUtil.multi(MATRIX, d1);
        d2 = MatrixUtil.multi(MATRIX, d2);
        o = MatrixUtil.multi(MATRIX, o);
    }
}
