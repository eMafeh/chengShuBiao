import util.MatrixUtil;
import util.MyTool;
import util.RGBStatus;

import javax.swing.*;
import java.awt.*;

public class RGBBoot {
    public static void main(String[] args) throws InterruptedException {
        JFrame main = new JFrame();
        RGBStatus rgb = new RGBStatus(new double[]{1, 2, 0},
                new double[]{0, 0.6, 0.8},
                MatrixUtil.fix(new double[]{1, 1, 1}));
        JComponent comp = new JComponent() {

            @Override
            protected void paintComponent(final Graphics g) {
                Graphics2D g2 = (Graphics2D) g;
                for (int x = 0; x < 256; x++) {
                    for (int y = 0; y < 256; y++) {
                        g2.setColor(rgb.getColorMix(x, y));
                        g2.fillRect(x * 2, y * 2, 2, 2);
                    }
                }
                rgb.change();
            }
        };
        EventQueue.invokeLater(() -> {
            MyTool.beDragged(main, comp);
            main.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
            main.setBounds(100, 100, 512, 512);
            main.setUndecorated(true);
            main.setOpacity(0.56f);
            comp.setPreferredSize(new Dimension(512, 512));
            main.add(comp);
            main.setVisible(true);
        });

        while (true) {
            EventQueue.invokeLater(comp::repaint);
            Thread.sleep(2);
        }
    }
}
