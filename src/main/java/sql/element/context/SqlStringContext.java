package sql.element.context;

import sql.common.Sxception;
import sql.element.ContextRule;
import sql.element.Section;
import sql.element.SqlHandler;
import sql.element.SubType;

/**
 * @author QianRui
 * {@link SubType.STRING}
 */
public class SqlStringContext implements ContextRule {
    private final char target;

    public SqlStringContext(final char target) {
        this.target = target;
    }

    @Override
    public Section use(final SqlHandler sql) {
        if (!sql.hit(target)) return null;
        SqlHandler.Marker marker = sql.marker();
        sql.next();
        StringBuilder builder = new StringBuilder();
        boolean normal = false;
        while (sql.hasNext()) {
            char c = sql.now();
            sql.next();
            if (!normal && c == target) {
                return new Section(marker, builder.toString(), SubType.STRING);
            }
            builder.append(c);
            if (normal) {
                normal = false;
            } else if (c == '\\') {
                normal = true;
            }
        }
        Sxception.fail("字符串没有结束");
        return null;
    }
}
