# ==============================================================================
# STANDARD ENVIRONMENT SETUP FOR JULIA PROJECTS
# ==============================================================================
# The 'using Pkg' statement loads Julia's built-in package management system,
# which allows us to programmatically install and manage dependencies.
using Pkg

# AUTOMATIC GTK DEPENDENCY INSTALLATION
# This section checks if the GTK library is already installed in the current Julia environment.
# The Base.UUID("1c23b2c9-d055-520e-82f4-750530d97b0a") is the unique identifier for the Gtk.jl package.
# If the package is not found, it automatically installs it using Pkg.add("Gtk").
# This ensures the script can run on any system without manual pre-installation steps.
if !haskey(Pkg.dependencies(), Base.UUID("1c23b2c9-d055-520e-82f4-750530d97b0a"))
    Pkg.add("Gtk")
end

# ==============================================================================
# PROJECT: PRO JULIA CALCULATOR APPLICATION
# VERSION: Final Stabilized Version with Gtk Namespace Compatibility
# DESCRIPTION: A modern graphical calculator built with Julia and Gtk framework
# ==============================================================================

# LOAD THE GTK GRAPHICS FRAMEWORK
# Gtk (GIMP Toolkit) is a cross-platform widget toolkit for creating GUI applications.
# By importing Gtk, we gain access to all window components (buttons, text entries, etc.)
# that will form the visual interface of our calculator application.
using Gtk

# ==============================================================================
# SECTION 1: APPLICATION STATE MANAGEMENT
# ==============================================================================
# The 'expression' variable is a Ref container that holds the current mathematical
# expression being built by the user. A Ref is used because it's a mutable container
# that allows us to modify the stored value inside functions without returning it.
# It starts as an empty string, and gets populated as the user clicks number/operator buttons.
expression = Ref("") 

# ==============================================================================
# SECTION 2: CASCADING STYLE SHEETS (CSS) STYLING FOR MODERN DARK THEME DESIGN
# ==============================================================================
# The GtkCssProvider is a Gtk component that applies CSS styling rules to GUI elements.
# This creates a modern dark theme with vibrant accent colors. Important CSS syntax notes:
#   - CSS comments use /* */ notation (not # which is reserved for hexadecimal color codes)
#   - Hexadecimal colors are in #RRGGBB format where each pair represents Red, Green, Blue intensity
#   - Classes (prefixed with .) are used to selectively style specific button types
#   - Pseudo-classes like :hover apply styling on user interactions

style_provider = GtkCssProvider(data="""
    /* Main window background: Deep dark gray (#121212) for reduced eye strain */
    window { background-color: #121212; }
    
    /* Grid container: Adds 15px margin to create breathing room */
    grid { margin: 15px; }
    
    /* Base button styling: Modern dark buttons with white text */
    button { 
        border-radius: 12px;           /* Rounded corners for modern appearance */
        background-color: #2c2c2c;     /* Very dark gray background */
        color: #ffffff;                /* Pure white text for maximum contrast */
        font-weight: bold;             /* Bold text for better readability */
        font-size: 18px;               /* Larger font size for easy interaction */
        border: none;                  /* Remove default button borders */
    }
    
    /* Hover effect: Button brightens and shows blue bottom border when user hovers mouse over it */
    button:hover { 
        background-color: #444444;         /* Lighter gray on hover */
        border-bottom: 2px solid #2196F3;  /* Blue accent border indicates interactivity */
    }
    
    /* CSS Classes for different button types (note: currently not applied due to Gtk limitations) */
    .clear-btn { background-color: #d32f2f; }      /* Red for Clear button - indicates destructive action */
    .delete-btn { background-color: #7b1fa2; }     /* Purple for Delete button */
    .operator-btn { background-color: #f57c00; }   /* Orange for mathematical operators (+, -, *, /) */
    .equal-btn { background-color: #1976d2; }      /* Blue for Equals button - highlights the main action */
    
    /* Display entry (text input field) */
    entry { 
        font-size: 32px;              /* Large font for easy readability of numbers */
        border-radius: 8px;           /* Slightly rounded corners */
        background-color: #1e1e1e;    /* Even darker background to distinguish from buttons */
        color: #00e676;               /* Bright green text resembling classic calculator displays */
        padding: 15px;                /* Internal spacing inside the input field */
        margin-bottom: 10px;          /* Space between display and button grid */
    }
    
    /* History/status label styling */
    label { 
        color: #aaaaaa;               /* Medium gray text for secondary information */
        font-size: 14px;              /* Smaller font than main display */
        margin-bottom: 5px;           /* Small space before the element below */
    }
""")

# ==============================================================================
# SECTION 3: USER INTERFACE ARCHITECTURE AND LAYOUT COMPOSITION
# ==============================================================================
# This section constructs the visual structure of the calculator application.
# The layout uses a hierarchical composition pattern where components are nested inside containers.

# Create the main application window with title and dimensions (400px width x 700px height)
# The window serves as the root container that holds all other visual elements
win = GtkWindow("Calculator", 400, 700)

# Create a vertical box container (GtkBox :v means vertical orientation)
# This container will hold the history label, display, and button grid stacked vertically
# The vbox arranges its children in a top-to-bottom layout
vbox = GtkBox(:v)
set_gtk_property!(vbox, :margin, 10)      # 10px margin on all sides of the vbox
set_gtk_property!(vbox, :spacing, 5)      # 5px space between each child element in vbox

# Create a label to display calculation history/previous expressions
# This shows what operation was just performed (e.g., "23 + 45 =")
history_label = GtkLabel("")
set_gtk_property!(history_label, :xalign, 1.0)  # Right-align the text (1.0 = right, 0.0 = left)

# Create the main display entry (text input/output field)
# This is the primary visual element showing the current number/expression being edited
display = GtkEntry()
set_gtk_property!(display, :text, "0")               # Initialize with "0"
set_gtk_property!(display, :editable, false)         # User cannot type directly; only buttons update it
set_gtk_property!(display, :xalign, 1.0)             # Right-align numbers (standard calculator behavior)
set_gtk_property!(display, :hexpand, true)           # Expand horizontally to fill available space

# Create the grid layout for calculator buttons
# A grid is a 2D layout manager that positions elements in rows and columns
grid = GtkGrid()
set_gtk_property!(grid, :column_spacing, 10)  # 10px horizontal space between button columns
set_gtk_property!(grid, :row_spacing, 10)     # 10px vertical space between button rows
set_gtk_property!(grid, :hexpand, true)       # Expand horizontally to fill window width
set_gtk_property!(grid, :vexpand, true)       # Expand vertically to fill remaining space (centers content)

# ==============================================================================
# SECTION 4: CORE CALCULATION AND EXPRESSION EDITING LOGIC
# ==============================================================================
# This function handles all button click events and implements the calculator's
# mathematical operations. It manages the expression string, performs calculations,
# and updates the display in real-time.

function on_button_click(label::String)
    if label == "C"
        # CLEAR BUTTON: Reset the calculator to initial state
        # This wipes out the entire expression and display, preparing for a new calculation
        expression[] = ""
        set_gtk_property!(display, :text, "0")
        set_gtk_property!(history_label, :label, "")
    
    elseif label == "DEL"
        # DELETE/BACKSPACE BUTTON: Remove the last character from the expression
        # This allows users to correct typing mistakes without clearing everything
        # The 'chop()' function efficiently removes the last character from a string.
        # This is important for large expressions as it's optimized for this operation.
        if !isempty(expression[])
            expression[] = chop(expression[])
            # Update the display to show the shortened expression, or "0" if now empty
            set_gtk_property!(display, :text, isempty(expression[]) ? "0" : expression[])
        end

    elseif label == "="
        # EQUALS BUTTON: Evaluate the mathematical expression and show the result
        # This is where Julia's metaprogramming capability shines:
        # - expression[] is a string like "23+45*2"
        # - Meta.parse() converts the string into an abstract syntax tree
        # - eval() executes that syntax tree and returns the numerical result
        # The try-catch block handles invalid expressions gracefully (e.g., "2++3")
        try
            result = eval(Meta.parse(expression[]))
            set_gtk_property!(history_label, :label, expression[] * " =")  # Show completed operation
            set_gtk_property!(display, :text, string(result))              # Show result
            expression[] = string(result)  # Prepare result for chaining: "50+3" is possible after
        catch
            # If expression is invalid, show error message and reset
            set_gtk_property!(display, :text, "Error")
            expression[] = ""
        end
    
    else
        # NUMBER AND OPERATOR BUTTONS: Append the clicked symbol to the expression string
        # This handles all digits (0-9), operators (+, -, *, /), and parentheses
        current = get_gtk_property(display, :text, String)
        
        # Smart input handling: If display shows "0" or "Error", replace it; otherwise append
        # This prevents expressions like "0" becoming "05" when user enters another digit
        if current == "0" || current == "Error"
             expression[] = label
        else
             expression[] *= label
        end
        set_gtk_property!(display, :text, expression[])
    end
end

# ==============================================================================
# SECTION 5: RESPONSIVE BUTTON GRID CONSTRUCTION
# ==============================================================================
# This section programmatically creates all 20 calculator buttons and positions them
# in a 5x4 grid layout. Using loops avoids repetitive code and makes the layout
# easy to modify later (change layout by altering the labels array or loops).

# Define the button labels in reading order (left-to-right, top-to-bottom)
# This array determines both the button text and their positions in the grid
labels = [
    "C", "DEL", "(", ")",      # Row 1: Clear, Delete, and parentheses
    "7", "8", "9", "/",        # Row 2: Numbers and division
    "4", "5", "6", "*",        # Row 3: Numbers and multiplication
    "1", "2", "3", "-",        # Row 4: Numbers and subtraction
    "0", ".", "+", "="         # Row 5: Zero, decimal point, addition, equals
]

# Nested loop to create buttons and position them in the grid
# Outer loop: i from 0 to 4 (5 rows)
# Inner loop: j from 0 to 3 (4 columns)
# Total: 5 × 4 = 20 buttons
for i in 0:4
    for j in 0:3
        # Calculate which label to use based on position
        # Formula: row_index * columns_per_row + column_index + 1
        # (The +1 is because Julia arrays are 1-indexed, not 0-indexed)
        idx = i * 4 + j + 1
        btn_text = labels[idx]
        
        # Create a new button with the label text
        btn = GtkButton(btn_text)
        
        # Configure button to expand and fill available grid space
        # Both horizontal and vertical expansion ensures buttons are large and easy to click
        set_gtk_property!(btn, :hexpand, true)
        set_gtk_property!(btn, :vexpand, true)

        # Attach the button click event handler
        # When user clicks this button, the on_button_click() function executes
        # with the button's text label as the argument
        signal_connect(btn, "clicked") do widget
            on_button_click(btn_text)
        end
        
        # Add button to grid at position [column, row]
        # Note: Gtk uses [col, row] ordering, not [row, col]
        # Grid positions are 1-indexed: [1,1] is top-left corner
        grid[j+1, i+1] = btn
    end
end

# ==============================================================================
# SECTION 6: FINAL ASSEMBLY AND APPLICATION RENDERING
# ==============================================================================
# This section combines all components (styling, display, buttons) into a cohesive
# application and starts the event loop to handle user interactions.

# Apply the CSS styling provider to the main window
# The 'ctx' variable gets the style context of the window (its styling properties)
# We then push the style_provider into it with priority 600 (higher values override lower ones)
ctx = Gtk.GAccessor.style_context(win)
Gtk.push!(ctx, style_provider, 600)

# Assemble the vertical box layout by adding components in order (top to bottom)
# This establishes the visual hierarchy: history label → display → button grid
push!(vbox, history_label)  # Show previous calculation at top
push!(vbox, display)        # Show current input/result in the middle
push!(vbox, grid)           # Show all buttons below

# Add the vertical box as the main content of the window
push!(win, vbox)

# Make all components visible and render the GUI
# 'showall()' recursively shows the window and all its child components
# This is the final step that actually displays the GUI to the user
showall(win)

# ==============================================================================
# APPLICATION EVENT LOOP FOR TERMINAL/NON-INTERACTIVE ENVIRONMENTS
# ==============================================================================
# This block handles the event loop for when the script runs outside the Julia REPL.
# The REPL (Read-Eval-Print Loop) has built-in event handling, but standalone scripts need explicit handling.

# Check if running interactively (in REPL) or non-interactively (direct execution)
if !isinteractive()
    # Create a condition variable that acts as a synchronization mechanism
    # The program will wait on this condition until the window is destroyed
    c = Condition()
    
    # Register a signal handler for the window's "destroy" event
    # When user clicks the X button to close the window, this handler executes
    signal_connect(win, :destroy) do widget
        # Notify the condition, which wakes up the waiting process below
        notify(c)
    end
    
    # Block execution here, waiting for the destroy signal
    # This keeps the application running and responsive to user input
    # Without this, the script would end immediately after creating the window
    wait(c)
end