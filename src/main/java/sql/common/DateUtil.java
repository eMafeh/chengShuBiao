package sql.common;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class DateUtil {
    private static final Map<String, ThreadLocal<SimpleDateFormat>> factory = new ConcurrentHashMap<>();

    public static Date parse(String timeStr, String format) {
        try {
            return get(format).get()
                    .parse(timeStr);
        } catch (ParseException e) {
            return null;
        }
    }

    private static ThreadLocal<SimpleDateFormat> get(String format) {
        return factory.computeIfAbsent(format, a -> ThreadLocal.withInitial(() -> new SimpleDateFormat(a)));
    }
}
