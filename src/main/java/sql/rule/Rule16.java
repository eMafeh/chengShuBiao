package sql.rule;

import sql.common.DateUtil;
import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;

import java.util.Date;
import java.util.List;

/**
 * @author QianRui
 * 脚本中禁止出现硬编码，例如年末日期写死成固定值的情况，应采取变量形式；
 */
public class Rule16 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> {
            for (int i = 0; i < sentence.size(); i++) {
                Section section = sentence.get(i);
                check(section, "yyyyMMdd");
                check(section, "yyyy-MM-dd");
            }
        });
    }

    private static void check(final Section section, final String format) {
        if (section.value.length() == format.length()) {
            Date parse = DateUtil.parse(section.value, format);
            if (parse != null)
                Sxception.fail(section.marker, -30, 20, "规范16:禁止出现硬编码年月日");
        }
    }
}
