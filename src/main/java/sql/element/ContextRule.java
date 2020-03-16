package sql.element;

import sql.element.context.KeyWordsContext;
import sql.element.context.NoteContext;
import sql.element.context.SpecialCharactersContext;
import sql.element.context.SqlStringContext;

import java.util.ArrayList;
import java.util.List;

/**
 * @author QianRui
 * 解析原始sql字符串的规则
 */
public interface ContextRule {
    List<ContextRule> ALL = new ArrayList<ContextRule>() {
        {
            //-- 之后认为是注释 直到换行
            add(NoteContext::use);
            //"  是一个字符串 内部的所有内容都是字符串 直到 "结束 但是 \"不算结束,直到换行没有",认为错误
            add(new SqlStringContext('"'));
            //'  是一个字符串 内部的所有内容都是字符串 直到 "结束 但是 \"不算结束,直到换行没有",认为错误
            add(new SqlStringContext('\''));
            // 结构字符单独成体系
            add(SpecialCharactersContext::use);
            // 单词提取 且转大写
            add(KeyWordsContext::use);
        }
    };

    Section use(SqlHandler line);
}