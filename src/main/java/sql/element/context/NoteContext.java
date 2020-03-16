package sql.element.context;

import sql.element.Section;
import sql.element.SqlHandler;
import sql.element.SubType;

/**
 * @author QianRui
 * {@link SubType.NOTE}
 */
public class NoteContext {
    public static Section use(final SqlHandler sql) {
        if (!sql.hit('-', '-')) return null;
        SqlHandler.Marker marker = sql.marker();
        StringBuilder builder = new StringBuilder();
        while (sql.hasNext()) {
            char c = sql.now();
            if (c != '\n') {
                builder.append(c);
                sql.next();
            } else {
                break;
            }
        }
        return new Section(marker, builder.toString(), SubType.NOTE);
    }

}
