package sql.common;

public class NumberUtil {
    public static boolean isNumber(String str) {
//?:0或1个, *:0或多个, +:1或多个 
        return str.matches("-?[0-9]+.？[0-9]*");
    }
}
