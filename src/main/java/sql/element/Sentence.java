package sql.element;

import sql.common.Sxception;

import java.util.ArrayList;
import java.util.List;

/**
 * @author QianRui
 * 一条以;结尾的语句
 */
public class Sentence {
    private final List<Section> list;

    public final IntactSentence intactSentence = new IntactSentence();

    private Sentence(final List<Section> list) {
        this.list = list;
        for (Section section : list) {
            if (!intactSentence.add(section)) {
                Sxception.fail(section, "结束括号前没有对应的开始括号");
            }
        }
        if (intactSentence.sub != null)
            Sxception.fail(list.get(0), "句尾缺少结束括号");
    }


    public static List<Sentence> toSentences(final List<Section> list) {
        List<Sentence> sentences = new ArrayList<>();
        List<Section> sectionList = new ArrayList<>();
        for (Section s : list) {
            //空格换行注释全部去除
            if (s.type == SubType.EMPTY || s.type == SubType.FEED || s.type == SubType.NOTE) {
                continue;
            }
            sectionList.add(s);
            if (s.type == SubType.END) {
                sentences.add(new Sentence(sectionList));
                sectionList = new ArrayList<>();
            }
        }
        return sentences;
    }

    public boolean hit(final String... rename) {
        m:
        for (int i = 0; i < list.size() - rename.length + 1; i++) {
            for (int j = 0; j < rename.length; j++) {
                if (!list.get(i + j).value.equals(rename[j])) continue m;
            }
            return true;
        }
        return false;
    }

    public static class IntactSentence implements Intact {
        public List<Intact> intacts = new ArrayList<>();
        private IntactSentence sub;

        IntactSentence() {
        }

        IntactSentence(final Section section) {
            intacts.add(section);
        }

        boolean add(final Section section) {
            if (sub == null) {
                if (section.type == SubType.SR || section.type == SubType.BR) {
                    intacts.add(section);
                    return false;
                }
                if (section.type == SubType.SL || section.type == SubType.BL) {
                    sub = new IntactSentence(section);
                    return true;
                }
                intacts.add(section);
                return true;
            } else {
                boolean add = sub.add(section);
                if (!add) {
                    intacts.add(sub);
                    sub = null;
                }
                return true;
            }
        }
    }

    public Section getFirst(final String rename) {
        for (Section section : list) {
            if (section.value.equals(rename)) return section;
        }
        return null;
    }

    public List<Section> getAll(final String rename) {
        ArrayList<Section> result = new ArrayList<>();
        for (Section section : list) {
            if (section.value.equals(rename)) result.add(section);
        }
        return result;
    }

    public int size() {
        return list.size();
    }

    public Section get(final int index) {
        return list.get(index);
    }
}
