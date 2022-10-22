
@resultBuilder public struct PageBuilder {
   public static func buildBlock(_ components: PageElement...) -> PageDescription {
       PageDescription(elements: components)
   }
}
