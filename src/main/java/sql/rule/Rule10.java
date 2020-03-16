package sql.rule;

import sql.common.Sxception;
import sql.element.Intact;
import sql.element.Section;
import sql.element.Sentence;

import java.util.List;

/**
 * @author QianRui
 * 一段查询语句中子查询不允许嵌套超过或者等于两层；
 */
public class Rule10 {
    public static void check(List<Sentence> sentences) {
        sentences.forEach(sentence -> check(sentence.intactSentence, 0));
    }

    private static void check(Sentence.IntactSentence intact, int num) {
        List<Intact> intacts = intact.intacts;
        boolean select = isSelect(intact);
        if (select && num > 1) {
            Sxception.fail(firstSection(intact).marker, 0, 50, "规范10:子查询最多1层");
            return;
        }
        intacts.stream()
                .filter(i -> i instanceof Sentence.IntactSentence)
                .forEach(i -> check((Sentence.IntactSentence) i, select ? num + 1 : num));
    }

    static Section firstSection(final Sentence.IntactSentence intact) {
        Intact sub = intact.intacts.get(0);
        if (sub instanceof Section)
            return (Section) sub;
        else if (sub instanceof Sentence.IntactSentence)
            return firstSection((Sentence.IntactSentence) sub);
        else throw new RuntimeException();
    }

    static boolean isSelect(Sentence.IntactSentence intact) {
        return intact.intacts.stream()
                .filter(i -> i instanceof Section)
                .anyMatch(i -> ((Section) i).value.equals("SELECT"));
    }
}
