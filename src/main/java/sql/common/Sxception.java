package sql.common;

import sql.element.Section;
import sql.element.SqlHandler;

import java.io.Serializable;
import java.util.*;
import java.util.stream.Collectors;

/**
 * @author QianRui
 * 错误信息收集
 */
public class Sxception {
    private static final Map<String, List<String>> fails = new HashMap<>();
    private static final List<Section> tables = new ArrayList<>();

    public static void fail(final SqlHandler.Marker marker, final int left, final int right, final String message) {
        fail(marker.after(left, right), marker.row, marker.offset, message);
    }

    public static void fail(final Section section, final String message) {
        fail(section.value, section.marker.row, section.marker.offset, message);
    }

    private static void fail(final String sql, final int row, final int offset, final String message) {
        fails.computeIfAbsent("[[[" + message + "]]]", k -> new ArrayList<>())
                .add("[[row" + row + ",offset" + offset + "]]      \"" + sql + "\"");
    }

    public static void fail(final Serializable... message) {
        fails.computeIfAbsent("", k -> new ArrayList<>())
                .add(Arrays.toString(message));
    }

    public static void show() {
        for (Map.Entry<String, List<String>> entry : fails.entrySet()) {
            System.out.println(entry.getKey());
            for (String s : entry.getValue()) {
                System.out.println(s);
            }
            System.out.println();
        }
        System.out.println("\n\n\n\n\n存在如下建表行为:\n" + tables.stream()
                .map(table -> "row" + table.marker.row + ",offset" + table.marker.offset + "  " + table.value)
                .collect(Collectors.joining("\n")));
    }

    public static void createTable(final Section section) {
        tables.add(section);
    }
}