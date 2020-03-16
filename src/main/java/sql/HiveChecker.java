package sql;


import sql.common.Sxception;
import sql.element.Section;
import sql.element.Sentence;
import sql.element.SqlHandler;
import sql.rule.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

/**
 * @author QianRui
 * hive 脚本验证
 */
public class HiveChecker {


    public static void main(String[] args) throws IOException {
        Path path = Paths.get("C:\\Users\\QianRui\\Documents\\SuningImFiles\\sn88382571\\fileRec\\pa.sql.txt");
        List<String> lines = Files.readAllLines(path);
        SqlHandler handler = new SqlHandler(lines);
        //解析后默认 大写
        List<Section> list = Section.toSections(handler);
        List<Sentence> sentences = Sentence.toSentences(list);
        Rule1.check(list);
        Rule2.check(list);
        //规范3已经在 解析阶段完成
        Rule4_5.check(sentences);
        Rule6.check(sentences);
        Rule7.check(sentences);
        Rule8.check(sentences);
        Rule9.check(sentences);
        Rule10.check(sentences);
        Rule11.check(sentences);
        Rule16.check(sentences);
        Rule14_19.check(sentences);
        Sxception.show();
    }
}
