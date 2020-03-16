package sql.rule;

import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 */
public class Rule11 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> {
            Section alter = sentence.get(0);
            Section table = sentence.get(1);
            if ("ALTER".equals(alter.value) && "TABLE".equals(table.value)) {
                Section rename = sentence.getFirst("RENAME");
                if (rename != null)
                    Sxception.fail(rename.marker, -10, 20, "规范11:不允许rename表后重新建表");
                Section cascade = sentence.getFirst("CASCADE");
                if (cascade == null)
                    Sxception.fail(alter.marker, 0, 50, "规范11:alter table命令需要加上CASCADE关键字");
            }
        });
    }
}
