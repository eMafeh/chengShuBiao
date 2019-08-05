import util.MatrixUtil;
import util.MyTool;
import util.RGBStatus;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.geom.Point2D;

public class ChengShuBiaoBoot {
    static final Dimension SCRENN_SIZE = Toolkit.getDefaultToolkit()
            .getScreenSize();
    static final int R = SCRENN_SIZE.height / 2 - 50;
    //    static final int R = 20;
    static final int d = 1000;
    static volatile int times = 0;
    static final JTextField timeInput = new JTextField() {
        {
            JTextField that = this;
            that.setBounds(5 * R / 3, 0, R / 3, R / 12);
            that.addKeyListener(new KeyAdapter() {
                @Override
                public void keyPressed(final KeyEvent e) {
                    if (e.getKeyCode() == KeyEvent.VK_ENTER) {
                        try {
                            times = (int) (Float.parseFloat(that.getText()) * 10);
                            e.consume();
                        } catch (Exception e1) {
                            //
                        }
                        that.setText(times / 10.0 + "");
                    }
                }
            });
        }
    };
    static volatile boolean rgb = true;
    static final JButton RGB_BUTTON = new JButton("RGB暂停") {
        {
            JButton that = this;
            that.setBounds(5 * R / 3, R / 12, R / 3, R / 12);
            that.addActionListener(new AbstractAction() {
                @Override
                public void actionPerformed(final ActionEvent e) {
                    rgb = !rgb;
                    that.setText(rgb ? "RGB暂停" : "动态RGB");
                }
            });
        }
    };
    static volatile boolean auto = true;
    static final JButton AUTO_BUTTON = new JButton("自动") {
        {
            JButton that = this;
            that.setBounds(5 * R / 3, R / 12 * 2, R / 3, R / 12);
            that.addActionListener(new AbstractAction() {
                @Override
                public void actionPerformed(final ActionEvent e) {
                    auto = !auto;
                    that.setText(auto ? "手动" : "自动");
                }
            });
        }
    };
    static final RGBStatus status = new RGBStatus(new double[]{1, 0, 0},
            new double[]{0, 0.6, 0.8},
            MatrixUtil.fix(new double[]{1, 2, 1}));
    static final JComponent comp = new JComponent() {
        @Override
        protected void paintComponent(final Graphics g) {
            double rt = times / 10.0;
            Graphics2D g2 = (Graphics2D) g;
            g2.draw(new Ellipse2D.Float(0, 0, 2 * R, 2 * R));
            for (int i = 0; i < d; i++) {
                float i1 = (float) (i * rt % d);
                g2.setColor(status.getColor(i, (int) i1));
                g2.draw(new Line2D.Float(circle(d, i), circle(d, i1)));
            }
        }
    };

    public static void main(String[] args) throws InterruptedException {
        JFrame main = new JFrame();
        EventQueue.invokeLater(() -> {
            main.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
            main.setBounds(0, 50, 2 * R, 2 * R);
            main.setUndecorated(true);
            main.setOpacity(0.5f);
            MyTool.beDragged(main, comp);
            comp.add(timeInput);
            comp.add(RGB_BUTTON);
            comp.add(AUTO_BUTTON);
            comp.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(final MouseEvent e) {
                    if (auto) {
                        if (e.getButton() == 2) {
                            auto = false;
                        }
                    } else {
                        if (e.getButton() == 1) {
                            times += e.getClickCount();
                        } else if (e.getButton() == 2) {
                            auto = true;
                        } else {
                            times -= e.getClickCount();
                        }
                    }
                    timeInput.setText(times / 10.0 + "");
                }
            });
            comp.setPreferredSize(new Dimension(2 * R, 2 * R));
            main.add(comp);
            main.setVisible(true);
        });
        while (true) {
            if (rgb) {
                status.change();
            }
            if (auto) {
                times++;
                timeInput.setText(times / 10.0 + "");
            }
            EventQueue.invokeLater(comp::repaint);
            Thread.sleep(10);
        }

    }

    private static Point2D.Float circle(final int d, final float i) {
        double a = 2 * Math.PI / d * i;
        float y = (float) (Math.sin(a) * R + R);
        float x = (float) (Math.cos(a) * R + R);
        return new Point2D.Float(x, y);
    }
}
