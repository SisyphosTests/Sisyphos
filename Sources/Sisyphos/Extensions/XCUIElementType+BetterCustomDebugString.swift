import XCTest


/// By default, `XCUIElement.ElementType` doesn't have a helpful debug string. It will always print
/// `__C.XCUIElementType` for every element type which gives no idea of which type the element is. This implementation
/// will print the actual element type, e.g. `.staticText` or `.other`.
extension XCUIElement.ElementType: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let elementType = ElementType(self) else { return "XCUIElement.ElementType(rawValue:\(rawValue))" }
        return String(describing: elementType)
    }
}


private enum ElementType: UInt, Codable, Hashable {

    case any = 0

    case other = 1

    case application = 2

    case group = 3

    case window = 4

    case sheet = 5

    case drawer = 6

    case alert = 7

    case dialog = 8

    case button = 9

    case radioButton = 10

    case radioGroup = 11

    case checkBox = 12

    case disclosureTriangle = 13

    case popUpButton = 14

    case comboBox = 15

    case menuButton = 16

    case toolbarButton = 17

    case popover = 18

    case keyboard = 19

    case key = 20

    case navigationBar = 21

    case tabBar = 22

    case tabGroup = 23

    case toolbar = 24

    case statusBar = 25

    case table = 26

    case tableRow = 27

    case tableColumn = 28

    case outline = 29

    case outlineRow = 30

    case browser = 31

    case collectionView = 32

    case slider = 33

    case pageIndicator = 34

    case progressIndicator = 35

    case activityIndicator = 36

    case segmentedControl = 37

    case picker = 38

    case pickerWheel = 39

    case `switch` = 40

    case toggle = 41

    case link = 42

    case image = 43

    case icon = 44

    case searchField = 45

    case scrollView = 46

    case scrollBar = 47

    case staticText = 48

    case textField = 49

    case secureTextField = 50

    case datePicker = 51

    case textView = 52

    case menu = 53

    case menuItem = 54

    case menuBar = 55

    case menuBarItem = 56

    case map = 57

    case webView = 58

    case incrementArrow = 59

    case decrementArrow = 60

    case timeline = 61

    case ratingIndicator = 62

    case valueIndicator = 63

    case splitGroup = 64

    case splitter = 65

    case relevanceIndicator = 66

    case colorWell = 67

    case helpTag = 68

    case matte = 69

    case dockItem = 70

    case ruler = 71

    case rulerMarker = 72

    case grid = 73

    case levelIndicator = 74

    case cell = 75

    case layoutArea = 76

    case layoutItem = 77

    case handle = 78

    case stepper = 79

    case tab = 80

    case touchBar = 81

    case statusItem = 82

    init?(_ elementType: XCUIElement.ElementType) {
        self.init(rawValue: elementType.rawValue)
    }
}

