import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class Calculator_Interface extends JFrame {
    private JTextField display;
    private StringBuilder currentInput = new StringBuilder();
    private double result = 0;
    private String operation = "";
    private boolean newNumber = true;

    public Calculator_Interface() {
        setTitle("Calculadora");
        setSize(400, 500);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setResizable(false);

        JPanel panel = new JPanel(new BorderLayout());
        
        display = new JTextField();
        display.setFont(new Font("Arial", Font.PLAIN, 24));
        display.setHorizontalAlignment(JTextField.RIGHT);
        display.setEditable(false);
        panel.add(display, BorderLayout.NORTH);

        JPanel buttonPanel = new JPanel(new GridLayout(4, 4, 5, 5));
        buttonPanel.setMargin(new Insets(10, 10, 10, 10));

        String[] buttons = {
            "7", "8", "9", "/",
            "4", "5", "6", "*",
            "1", "2", "3", "-",
            "0", ".", "=", "+"
        };

        for (String btn : buttons) {
            JButton button = new JButton(btn);
            button.setFont(new Font("Arial", Font.PLAIN, 18));
            button.addActionListener(new ButtonClickListener(btn));
            buttonPanel.add(button);
        }

        JButton clearBtn = new JButton("C");
        clearBtn.setFont(new Font("Arial", Font.PLAIN, 18));
        clearBtn.addActionListener(e -> clear());
        buttonPanel.add(clearBtn);

        panel.add(buttonPanel, BorderLayout.CENTER);
        add(panel);
        setVisible(true);
    }

    private class ButtonClickListener implements ActionListener {
        private String value;

        public ButtonClickListener(String value) {
            this.value = value;
        }

        @Override
        public void actionPerformed(ActionEvent e) {
            if (Character.isDigit(value.charAt(0)) || value.equals(".")) {
                if (newNumber) {
                    currentInput = new StringBuilder(value);
                    newNumber = false;
                } else {
                    currentInput.append(value);
                }
                display.setText(currentInput.toString());
            } else if (value.equals("=")) {
                calculate();
            } else {
                if (!currentInput.toString().isEmpty()) {
                    if (!operation.isEmpty()) {
                        calculate();
                    }
                    result = Double.parseDouble(currentInput.toString());
                    operation = value;
                    newNumber = true;
                }
            }
        }
    }

    private void calculate() {
        if (!operation.isEmpty() && !currentInput.toString().isEmpty()) {
            double num = Double.parseDouble(currentInput.toString());
            switch (operation) {
                case "+": result += num; break;
                case "-": result -= num; break;
                case "*": result *= num; break;
                case "/": result = num != 0 ? result / num : 0; break;
            }
            display.setText(String.valueOf(result));
            currentInput = new StringBuilder();
            operation = "";
            newNumber = true;
        }
    }

    private void clear() {
        currentInput = new StringBuilder();
        result = 0;
        operation = "";
        newNumber = true;
        display.setText("");
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(Calculator_Interface::new);
    }
}