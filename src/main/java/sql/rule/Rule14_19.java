package sql.rule;

import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 * 19 建表语句务必指定表数据存储类型，
 * 1.非T层表统一建为Rcfile格式；
 * 2.T层建为：LazySimpleSerDe，并需在IDE中配置数据交换任务时配置压缩相关参数；
 * <p>
 * 14 变更脚本中需检查不能存在有表创建在其非所属系统数据库的情况；
 */
public class Rule14_19 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(s -> {
            int index = 0;
            boolean create = "CREATE".equals(s.get(index).value);
            if (!create) return;
            for (int i = 0; i < 5; i++) {
                index++;
                if ("TABLE".equals(s.get(index).value)) {
                    index++;
                    Section section = getTable(index, s);
                    String tableName = section.value;
                    Sxception.createTable(section);
                    boolean tdata = tableName.replaceAll("`", "")
                            .startsWith("TDATA");
                    boolean hit = s.hit("STORED", "AS", "RCFILE");
                    if (tdata) {
                        if (hit)
                            Sxception.fail(section.marker, -30, 20,
                                    "规范19:T层建表不可以建表配置压缩,在IDE配置");
                    } else {
                        if (!hit)
                            Sxception.fail(section.marker, -30, 20,
                                    "规范19:非T层建表要配置 STORED AS Rcfile");
                    }
                    return;
                }
            }
        });
    }

    private static Section getTable(int index, Sentence sentence) {
        Section section = sentence.get(index);
        if (section.value.equals("IF")) return sentence.get(index + 3);
        else return section;
    }
}
