package sql.rule;

import sql.element.Section;
import sql.element.SubType;
import sql.common.Sxception;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static sql.element.SubType.*;

/**
 * @author QianRui
 */
public class Rule1 {
    //代码头部添加 如下项目
    private static final List<String> HEAD = new ArrayList<>(Arrays.asList(
            "脚本名称", "功能描述", "作者和日期", "直属经理", "目标表",
            "数据来源表"/*(建议也加上表的中文描述)*/, "修改历史"));

    public static void check(List<Section> list) {
        checkA(list);
        checkB(list);
    }

    //规范1前半部
    private static void checkA(List<Section> list) {
        List<String> notes = new ArrayList<>();
        for (final Section section : list) {
            if (section.type == SubType.EMPTY) continue;
            if (section.type == NOTE) {
                notes.add(section.value.trim());
            } else if (section.type != FEED) {
                break;
            }
        }
        List<String> collect = HEAD.stream()
                .filter(h -> notes.stream()
                        .anyMatch(note -> note.contains(h)))
                .collect(Collectors.toList());
        if (collect.size() != 0) {
            Sxception.fail("规范1:代码头部未添加如下注释条目", collect.toString());
        }
    }

    //规范1后半部
    private static void checkB(final List<Section> list) {
        list.stream()
                .filter(r -> r.type == NOTE && r.value.length() > 80)
                .forEach(r -> Sxception.fail(r, "规范1:注释每行少于80个字符"));
    }

}
