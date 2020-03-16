package sql.element;

import java.util.ArrayList;
import java.util.List;

/**
 * @author QianRui
 * 单个连续体
 */
public class Section implements Intact {
    public final SqlHandler.Marker marker;
    public final String value;

    public final SubType type;


    public Section(final SqlHandler.Marker marker, final String value, final SubType type) {
        this.marker = marker;
        this.value = value;
        this.type = type;
    }

    public static List<Section> toSections(final SqlHandler handler) {
        handler.restate();
        List<Section> list = new ArrayList<>();
        while (handler.hasNext()) {
            for (ContextRule rule : ContextRule.ALL) {
                Section use = rule.use(handler);
                if (use != null) {
                    list.add(use);
                    break;
                }
            }
        }
        return list;
    }

    @Override
    public String toString() {
        return value;
    }
}





