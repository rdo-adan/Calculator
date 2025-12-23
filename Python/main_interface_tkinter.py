import tkinter as tk
from tkinter import messagebox

class Calculator:
    def __init__(self, root):
        self.root = root
        self.root.title("Calculator")
        self.root.geometry("300x400")
        self.root.resizable(False, False)

        # String variable to store the current expression
        self.expression = ""

        # Entry widget to display the calculation/result
        # Justify set to right for standard calculator feel
        self.display = tk.Entry(root, font=("Arial", 24), borderwidth=5, relief="flat", justify='right')
        self.display.grid(row=0, column=0, columnspan=4, padx=10, pady=20, sticky="nsew")

        # Define button labels in a list of lists (grid layout)
        buttons = [
            ['7', '8', '9', '/'],
            ['4', '5', '6', '*'],
            ['1', '2', '3', '-'],
            ['C', '0', '=', '+']
        ]

        # Create and place buttons using a loop
        for r, row in enumerate(buttons):
            for c, char in enumerate(row):
                # Using a lambda function to pass the specific character to the method
                button = tk.Button(root, text=char, width=5, height=2, font=("Arial", 14),
                                   command=lambda val=char: self.on_button_click(val))
                button.grid(row=r+1, column=c, padx=5, pady=5, sticky="nsew")

        # Configure grid weights so buttons expand evenly
        for i in range(5):
            self.root.grid_rowconfigure(i, weight=1)
        for i in range(4):
            self.root.grid_columnconfigure(i, weight=1)

    def on_button_click(self, char):
        """Handles button click events based on the character input."""
        if char == 'C':
            self.expression = ""
            self.update_display()
        elif char == '=':
            self.calculate_result()
        else:
            self.expression += str(char)
            self.update_display()

    def update_display(self):
        """Updates the text shown in the Entry widget."""
        self.display.delete(0, tk.END)
        self.display.insert(0, self.expression)

    def calculate_result(self):
        """Evaluates the mathematical expression and handles errors."""
        try:
            # eval() parses the string as a Python expression
            result = str(eval(self.expression))
            self.display.delete(0, tk.END)
            self.display.insert(0, result)
            self.expression = result  # Allow further operations on the result
        except ZeroDivisionError:
            messagebox.showerror("Error", "Cannot divide by zero")
            self.expression = ""
            self.update_display()
        except Exception:
            messagebox.showerror("Error", "Invalid Expression")
            self.expression = ""
            self.update_display()

if __name__ == "__main__":
    # Initialize the main window and start the application
    root = tk.Tk()
    calc = Calculator(root)
    root.mainloop()