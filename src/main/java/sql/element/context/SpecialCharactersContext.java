package sql.element.context;

import sql.element.Section;
import sql.element.SqlHandler;
import sql.element.SubType;

/**
 * @author QianRui
 * {@link SubType.specialCharacters}
 */
public class SpecialCharactersContext {
    public static Section use(final SqlHandler sql) {
        for (SubType value : SubType.NO_QUOTE_SPECIAL_CHARACTERS) {
            if (sql.hit(value.c)) {
                Section section = new Section(sql.marker(), String.valueOf(value.c), value);
                sql.next();
                return section;
            }
        }
        return null;
    }
}
