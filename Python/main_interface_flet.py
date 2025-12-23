import flet as ft # Importing the Flet library as 'ft' for shorter access

# We define a class that inherits from 'ft.Column' to create a custom reusable UI component
class CalculatorApp(ft.Column):
    def __init__(self) -> None:
        super().__init__() # Initializes the parent ft.Column class
        
        # Internal variable to track the mathematical string (e.g., "1+2")
        self.expression: str = ""
        
        # Set the total width of this vertical column
        self.width: int = 350
        
        # Center the items (TextField, Rows) horizontally inside this column
        self.horizontal_alignment: ft.CrossAxisAlignment = ft.CrossAxisAlignment.CENTER

        # ft.Text is a simple control to display labels. This one acts as our history log.
        self.history: ft.Text = ft.Text(
            value="", 
            color=ft.Colors.BLUE_GREY_200, 
            size=14
        )
        
        # ft.TextField is an input box. We use it as the main calculator screen.
        self.display: ft.TextField = ft.TextField(
            value="0",                          # Default starting text
            text_align=ft.TextAlign.RIGHT,      # Align numbers to the right like a real calculator
            width=350,                          # Match the column width
            text_size=36,                       # Make numbers large and readable
            read_only=True,                     # Prevent the user from typing directly via keyboard
            border_radius=15,                   # Give it rounded corners
            bgcolor=ft.Colors.BLUE_GREY_900,    # Set a dark background color
            border_color=ft.Colors.BLUE_700,    # Set the color of the box outline
            content_padding=20                  # Add internal spacing so text doesn't touch the edges
        )

        # 'self.controls' is a list where we put all the items that will appear on the screen
        self.controls = [
            self.history, # Show history first (at the top)
            self.display, # Show the main screen below history
            
            # ft.Row creates a horizontal line of controls (buttons)
            ft.Row(
                controls=[
                    self.create_button("C", ft.Colors.RED_ACCENT_700),
                    self.create_button("(", ft.Colors.BLUE_GREY_700),
                    self.create_button(")", ft.Colors.BLUE_GREY_700),
                    self.create_button("/", ft.Colors.AMBER_800),
                ],
            ),
            # Each Row below represents a line of numbers and operators
            ft.Row(
                controls=[
                    self.create_button("7"), self.create_button("8"), 
                    self.create_button("9"), self.create_button("*", ft.Colors.AMBER_800),
                ]
            ),
            ft.Row(
                controls=[
                    self.create_button("4"), self.create_button("5"), 
                    self.create_button("6"), self.create_button("-", ft.Colors.AMBER_800),
                ]
            ),
            ft.Row(
                controls=[
                    self.create_button("1"), self.create_button("2"), 
                    self.create_button("3"), self.create_button("+", ft.Colors.AMBER_800),
                ]
            ),
            ft.Row(
                controls=[
                    # 'expand=2' makes the '0' button twice as wide as others
                    self.create_button("0", expand=2),
                    self.create_button("."),
                    self.create_button("=", ft.Colors.BLUE_800),
                ]
            ),
        ]

    def create_button(self, text: str, color: str = None, expand: int = 1) -> ft.Container:
        """Helper to build styled buttons. We use Container for more styling flexibility."""
        return ft.Container(
            # ft.Text inside the container displays the button label
            content=ft.Text(text, size=20, weight=ft.FontWeight.BOLD),
            alignment=ft.alignment.center,       # Center the text inside the box
            bgcolor=color if color else ft.Colors.GREY_900, # Use custom color or default grey
            border_radius=10,                    # Slightly rounded button corners
            height=70,                           # Fixed height for all buttons
            expand=expand,                       # Controls how the button fills the horizontal space
            on_click=lambda _: self.process_input(text), # Tells Flet what function to run when clicked
            ink=True,                            # Visual 'ripple' effect when clicked (Material Design)
        )

    def process_input(self, data: str) -> None:
        """The brain of the calculator: processes clicks and updates values."""
        if data == "C":
            self.expression = ""
            self.display.value = "0"
            self.history.value = ""
        
        elif data == "=":
            try:
                self.history.value = f"{self.expression} =" # Move calculation to history
                # eval() takes a string like "2+2" and returns the integer 4
                self.display.value = str(eval(self.expression))
                self.expression = self.display.value # Allow user to continue from the result
            except Exception:
                self.display.value = "Error"
                self.expression = ""
        
        else:
            # If screen shows '0' or 'Error', replace it; otherwise, append the new digit
            if self.display.value in ("0", "Error"):
                self.expression = data
            else:
                self.expression += data
            self.display.value = self.expression

        # CRITICAL: In Flet, you must call update() to refresh the visual screen after changing values
        self.update()

def main(page: ft.Page) -> None:
    """Configures the main application window."""
    page.title = "Calculator"
    page.window.width = 400
    page.window.height = 600
    page.window.resizable = False
    page.theme_mode = ft.ThemeMode.DARK # Force Dark Mode
    
    # Align the entire calculator component in the center of the window
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    calc = CalculatorApp() # Create an instance of our calculator class

    # Function to catch keyboard strokes from the user's computer
    def on_keyboard(e: ft.KeyboardEvent) -> None:
        valid_keys = "0123456789+-*/()."
        if e.key in valid_keys:
            calc.process_input(e.key)
        elif e.key == "Enter":
            calc.process_input("=")
        elif e.key in ("Backspace", "Delete"):
            calc.process_input("C")

    # Link the keyboard function to the Flet page event listener
    page.on_keyboard_event = on_keyboard
    
    # Add the calculator instance to the visual page
    page.add(calc)

# The standard Python entry point
if __name__ == "__main__":
    ft.app(target=main) # Starts the application