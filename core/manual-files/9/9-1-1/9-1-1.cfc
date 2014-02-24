<cfcomponent>
<cfoutput>
<cffunction name="index" access="public">
<p>Paragraph with a <a href="##">link</a></p>

<p>Glossary terminology should be <em>emphasized</em>.</p>
<p>User actions should be <strong>bold</strong>.</p>
<p>Styles for <span class="zdoc-buttontext">Buttons</span> and <span class="zdoc-menutext zdoc-rightarrowbox">Menu Items</span> <span class="zdoc-menutext zdoc-rightarrowbox">with</span> <span class="zdoc-menutext">arrows</span>.</p>
<p><span class="zdoc-codetext">Code</span> text style.</p>
<h2>Unordered List - Long headings will auto wrap the text when the line is longer like this</h2>
<ul>
<li>Item1</li>
<li>Item2</li>
</ul>

<h2>Ordered List</h2>
<ol>
<li>Item1</li>
<li>Item2</li>
</ol>

<h3>Heading 3</h3>

<div class="zdoc-important"><h3>Important</h3>
<p>We bring attention to important information with this box.</p>
</div>
<div class="zdoc-tip"><h3>Tip</h3>
<p>Recommendations and best practices to simplify your work</p></div>
<div class="zdoc-caution"><h3>Caution</h3>
<p>Notes that should be carefully considered.</p></div>
<div class="zdoc-warning"><h3>Warning</h3>
<p>Serious problems could arise if warnings are ignored.</p></div>
</cffunction>
</cfoutput>
</cfcomponent>