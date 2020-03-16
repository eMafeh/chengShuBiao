package sql.rule;

import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 * 一段查询语句中子查询和union all合计不能超过或等于3个；
 * 子查询和union all 都会增加一个 select .,最多<3+1个
 */
public class Rule9 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> {
            List<Section> select = sentence.getAll("SELECT");
            if (select.size() > 3) {
                //规范9 任务中不允许自行设置hive参数，如需配置请向平台维护人员陆瑜胄说明情况
                Sxception.fail(select.get(0).marker, 0, 50, "规范9:子查询和union all合计最多2个");
            }
        });
    }
}
