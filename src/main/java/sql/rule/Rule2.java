package sql.rule;

import sql.common.Sxception;
import sql.element.Section;
import sql.element.SubType;

import java.util.List;

import static sql.element.SubType.FEED;
import static sql.element.SubType.NOTE;

/**
 * @author QianRui
 */
public class Rule2 {
    public static void check(List<Section> list) {
        int state = 0;
        for (final Section section : list) {
            if (section.type == SubType.EMPTY) continue;
            SubType type = section.type;
            //注释->2,语句->1
            //0:换行->0,语句 fail
            //2:换行->2
            //1:换行->3
            //3:换行->0
            if (type == NOTE) state = 2;
            else if (type == FEED) switch (state) {
                case 0:
                    break;
                case 2:
                    break;
                case 1:
                    state = 3;
                    break;
                case 3:
                    state = 0;
                    break;
                default:
                    throw new RuntimeException();
            }
            else {
                if (state == 0) {
                    Sxception.fail(section.marker, 0, 50, "规范2:每段sql前(sql前存在空行)都必须添加注释");
                }
                state = 1;
            }
        }
    }
}
