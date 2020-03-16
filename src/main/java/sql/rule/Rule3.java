package sql.rule;

import sql.element.SqlHandler;
import sql.common.Sxception;

/**
 * @author QianRui
 */
public class Rule3 {
    public static void check(final char aChar, final SqlHandler handler) {
        if (aChar == '\t')
            Sxception.fail(handler.marker(), -10, 10, "规范3:脚本不允许有tab键");
    }
}
