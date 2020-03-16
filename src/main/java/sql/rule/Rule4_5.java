package sql.rule;

import sql.common.NumberUtil;
import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 */
public class Rule4_5 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> {
            Section first = sentence.get(0);
            if (first.value.contains("SELECT"))
                //规范4 跑批任务脚本中不允许只有select查询空跑，而不对查询出来数据进行insert等相关处理的
                Sxception.fail(first.marker, 0, 50, "规范4:每段sql不允许以select开头空跑");
            else if (first.value.contains("SET")) {
                if (NumberUtil.isNumber(sentence.get(3).value))
                    //规范5 任务中不允许自行设置hive参数，如需配置请向平台维护人员陆瑜胄说明情况
                    Sxception.fail(first.marker, 0, 50, "规范5:任务中不允许自行设置hive参数");
            }
        });
    }
}
