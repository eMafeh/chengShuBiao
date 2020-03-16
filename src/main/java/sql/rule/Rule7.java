package sql.rule;

import sql.common.Sxception;
import sql.element.Intact;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 */
public class Rule7 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> check(sentence.intactSentence));
    }

    private static void check(Sentence.IntactSentence intact) {
        List<Intact> intacts = intact.intacts;
        intacts.stream()
                .filter(sub -> sub instanceof Sentence.IntactSentence)
                .map(sub -> (Sentence.IntactSentence) sub)
                .forEach(Rule7::check);
        for (int i = 0; i < intacts.size(); i++) {
            Intact sub = intacts.get(i);
            if (!(sub instanceof Section)) continue;
            Section order = (Section) sub;
            if (!order.value.equals("ORDER")) continue;
            Intact by = intacts.get(i + 1);
            if (by instanceof Section && ((Section) by).value.equals("BY")) {
                //确认是 order by语句,使用limit限制
                for (int j = i + 1; j < intacts.size(); j++) {
                    Intact limit = intacts.get(j);
                    if (limit instanceof Section && ((Section) limit).value.equals("LIMIT"))
                        //每个单句至多只有一次limit
                        return;
                }
                Sxception.fail(order.marker, -30, 20, "规范7:order by语句使用limit限制");
            }
        }
    }
}
