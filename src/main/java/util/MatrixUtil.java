package util;

import java.util.stream.DoubleStream;

public class MatrixUtil {

    private static final double[][] E3 = {
            {1, 0, 0},
            {0, 1, 0},
            {0, 0, 1}
    };

    public static double[] fix(double[] vector) {
        double length = length(vector);
        if (length == 0) return vector;
        for (int i = 0; i < vector.length; i++) {
            vector[i] /= length;
        }
        return vector;
    }

    private static double length(final double[] vector) {
        return Math.sqrt(DoubleStream.of(vector)
                .map(v -> v * v)
                .sum());
    }

    public static double[] multi(double[][] matrix, double[] old) {
        double[] result = new double[matrix[0].length];
        for (int i = 0; i < result.length; i++) {
            for (int j = 0; j < old.length; j++) {
                result[i] += old[j] * matrix[j][i];
            }
        }
        return result;
    }

    public static double[][] doc(double θ, double[] k) {
        fix(k);
        double cos = Math.cos(θ);
        double sin = Math.sin(θ);
        return multi(multi(cos, E3), multi(1 - cos, new double[][]{
                {k[0] * k[0], k[1] * k[0], k[2] * k[0]},
                {k[0] * k[1], k[1] * k[1], k[2] * k[1]},
                {k[0] * k[2], k[1] * k[2], k[2] * k[2]}
        }), multi(sin, new double[][]{
                {0, -k[2], k[1]},
                {k[2], 0, -k[0]},
                {-k[1], k[0], 0}
        }));
    }

    private static double[][] multi(final double[][]... matrixs) {
        double[][] result = new double[matrixs[0].length][matrixs[0][0].length];
        for (double[][] matrix : matrixs) {
            for (int i = 0; i < matrix.length; i++) {
                double[] vector = matrix[i];
                for (int j = 0; j < vector.length; j++) {
                    result[i][j] += vector[j];
                }
            }
        }
        return result;
    }

    private static double[][] multi(final double c, final double[][] matrix) {
        double[][] result = new double[matrix.length][matrix[0].length];
        for (int i = 0; i < matrix.length; i++) {
            double[] vector = matrix[i];
            for (int j = 0; j < vector.length; j++) {
                result[i][j] = vector[j] * c;
            }
        }
        return result;
    }
}
