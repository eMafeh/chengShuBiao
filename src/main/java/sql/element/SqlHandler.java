package sql.element;

import sql.rule.Rule3;

import java.util.List;

/**
 * @author QianRui
 * 将文件转化为字符流,并未后续转化提供支持
 */
public class SqlHandler {
    private final char[] chars;
    private int row;
    private int offset;
    private int index;

    public Marker marker() {
        return new Marker(chars, row, offset, index);
    }

    public static class Marker {
        private final char[] chars;
        public final int row;
        public final int offset;
        public final int index;

        private Marker(final char[] chars, final int row, final int offset, final int index) {
            this.chars = chars;
            this.row = row;
            this.offset = offset;
            this.index = index;
        }

        public String after(int left, int right) {
            StringBuilder builder = new StringBuilder();
            int start = Math.min(Math.max(index + left, 0), chars.length);
            int end = Math.max(Math.min(index + right, chars.length), 0);
            for (int i = start; i < end; i++) {
                builder.append(chars[i]);
            }
            return builder.toString();
        }
    }

    public SqlHandler(List<String> lines) {
        chars = String.join(String.valueOf(SubType.FEED.c), lines)
                .toCharArray();
    }

    void restate() {
        row = 1;
        offset = 0;
        index = 0;
    }

    public boolean hit(char... targets) {
        if (chars.length - index < targets.length) return false;
        for (int i = 0; i < targets.length; i++) {
            if (chars[index + i] != targets[i]) {
                return false;
            }
        }
        return true;
    }

    public boolean hasNext() {
        return index < chars.length;
    }

    public char now() {
        return chars[index];
    }

    public void next() {
        if (chars[index] == '\n') {
            row++;
            offset = 0;
        }
        index++;
        offset++;
        if (hasNext()) Rule3.check(chars[index], this);
    }

    public int getRow() {
        return row;
    }

    public int getOffset() {
        return offset;
    }
}
