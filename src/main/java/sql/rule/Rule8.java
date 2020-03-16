package sql.rule;

import sql.common.Sxception;
import sql.element.Intact;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 */
public class Rule8 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> check(sentence.intactSentence));
    }

    private static void check(Sentence.IntactSentence intact) {
        List<Intact> intacts = intact.intacts;
        intacts.stream()
                .filter(sub -> sub instanceof Sentence.IntactSentence)
                .map(sub -> (Sentence.IntactSentence) sub)
                .forEach(Rule8::check);
        for (int i = 0; i < intacts.size(); i++) {
            Intact sub = intacts.get(i);
            if (sub instanceof Section) {
                Section field = (Section) sub;
                //continue 多个 join 都要判断
                if (field.value.equals("JOIN")) {
                    if (on(intacts.get(i + 2))) continue;
                    if (on(intacts.get(i + 3))) continue;
                    if (on(intacts.get(i + 4))) continue;
                    Sxception.fail(field.marker, -20, 30 , "规范8:不允许有笛卡尔积查询");
                }
            }
        }
    }

    private static boolean on(Intact intact) {
        return intact instanceof Section && ((Section) intact).value.equals("ON");
    }
}
