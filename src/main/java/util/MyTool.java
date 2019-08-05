package util;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;

public class MyTool {
    public static void beDragged(JFrame main, JComponent comp) {
        comp.addMouseMotionListener(new MouseMotionAdapter() {
            int xx;
            int yy;
            long last;

            @Override
            public void mouseDragged(final MouseEvent e) {
                long when = e.getWhen();
                if (when - last > 100) {
                    xx = e.getX();
                    yy = e.getY();
                }
                last = when;
                move(main, e.getX() - xx, e.getY() - yy);
            }
        });
    }

    private static void move(final JFrame main, final int dx, final int dy) {
        Point location = main.getLocation();
        main.setLocation(location.x + dx, location.y + dy);
    }
}
