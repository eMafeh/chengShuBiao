package sql.element;

import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author QianRui
 * 标记 {@link Section.type}
 */
public enum SubType {
    //注释
    NOTE,
    //空格 换行
    EMPTY(' '), FEED('\n'),
    //系统字段 用户字段,数字
    KEYWORDS,
    //分隔符
    COMMA(','), EQUAL('='), SINGLE_QUOTE('\''), DOUBLE_QUOTE('"'),
    //用户字符串
    STRING,
    //结构字符
    SL('('), SR(')'),
    BL('{'), BR('}'),
    FIELD(','), END(';');

    SubType() {
        this.c = 0;
    }

    public final char c;

    SubType(final char c) {
        this.c = c;
    }

    //特殊的单个字符
    public static final SubType[] NO_QUOTE_SPECIAL_CHARACTERS = Stream.of(values())
            .filter(s -> s.c != 0)
            .filter(s -> s != SINGLE_QUOTE && s != DOUBLE_QUOTE)
            .collect(Collectors.toList())
            .toArray(new SubType[0]);
    //特殊的单个字符
    private static final SubType[] specialCharacters = Stream.of(values())
            .filter(s -> s.c != 0)
            .collect(Collectors.toList())
            .toArray(new SubType[0]);

    public static boolean hit(final char c) {
        for (SubType s : specialCharacters) {
            if (s.c == c) return true;
        }
        return false;
    }
}