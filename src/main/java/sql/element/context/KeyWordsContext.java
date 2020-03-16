package sql.element.context;

import sql.element.Section;
import sql.element.SqlHandler;
import sql.element.SubType;

/**
 * @author QianRui
 * {@link SubType.KEYWORDS}
 */
public class KeyWordsContext {
    public static Section use(final SqlHandler sql) {
        SqlHandler.Marker marker = sql.marker();
        StringBuilder builder = new StringBuilder();
        while (sql.hasNext()) {
            final char c = sql.now();
            if (SubType.hit(c)) {
                break;
            } else {
                builder.append(c);
                sql.next();
            }
        }
        return new Section(marker, builder.toString()
                .toUpperCase(), SubType.KEYWORDS);
    }
}
