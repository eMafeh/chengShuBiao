package sql.rule;

import sql.common.Sxception;
import sql.element.Intact;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 * 分区表的查询必须使用分区字段过滤条件，不允许查询全部分区，如有特殊情况请向平台维护人员程宏明说明；
 * stat_dt = XXX或者data_date= XXXX
 */
public class Rule6 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> check(sentence.intactSentence));
    }

    private static void check(final Sentence.IntactSentence intact) {
        List<Intact> intacts = intact.intacts;
        intacts.stream()
                .filter(i -> i instanceof Sentence.IntactSentence)
                .map(i -> (Sentence.IntactSentence) i)
                .forEach(Rule6::check);
        if (Rule10.isSelect(intact)) {
            if (intacts.stream()
                    .filter(sub -> sub instanceof Section)
                    .map(sub -> ((Section) sub).value)
                    .noneMatch(value -> value.endsWith("STAT_DT") || value.endsWith("DATA_DATE"))) {
                Sxception.fail(Rule10.firstSection(intact).marker, 0, 50,
                        "规范6:表的查询必须使用分区字段过滤条件，不允许查询全部分区");
            }
        }
    }
}
