require 'redcarpet'

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
  autolink: true,
  lax_spacing: true,
  fenced_code_blocks: true,
  disable_indented_code_blocks: true,
  underline: true,
  footnotes: true,
  no_intra_emphasis: true,
)

original_md = "This was my breakfast on Wednesday, and I will use this toot to open-source my wrap wrapping ingredients. 🌮

ababa
wawawa
uiuiui

As you can see, my wraps consist of
* wrap (fried in a frying pan)
* tzatziki (consisting of quark, a store-bought herbal mixture made for salad seasoning, garlic, and some freshly-cut chive from our garden)
* salad (also fried in a frying pan ^^)
* couscous
* carrot splinters (fried in a  frying pan with oil and soy sauce)
* falafels
* toothpicks (only for holding it together; do not eat!!)

These ingredients are listed in the order in which they are stacked on the wrap before I fold it, and one frying pan suffices to make them (unless you happen to be pan, in which case it takes two).

#food

foo foo
bar bar"

original_md = "I'm really baffled by the mental gymnastics of conservative elder German comedians who somehow take the iron stance that both (a) comedy is important for a democracy and (b) comedy is morally allowed to make fun of whatever it pleases, without realizing that with great importance comes great responsibility, and that great responsibility implies being morally obligated to think before talking, especially about the consequences of ones jokes and actions.
It's not that hard to grasp, really, but apparently, their goal is to remain a jester who juggles with daggers in a crowd of people, aka a fool."

html = markdown.render(original_md)

puts "resultign html (raw):"
puts html

html = html.gsub("</p>\n\n<ul>", "</p><ul>")
# add line breaks:
html = html.gsub("\n\n", "<p></p>")
html = html.gsub("\n", "<br/>")
html = html.delete("\n")
# ^ This turns \n\n into <p></p><p></p>
#   and          \n into <br>
# html = simple_format(html, {}, sanitize: false)  # <-- the old code for that purpose
# remove last two empty paragraphs:
if html.end_with?("<p></p>")
  html = html.sub("<p></p>", "")
end
if html.end_with?("<p></p>")
  html = html.sub("<p></p>", "")
end
# remove linebreaks inside bullet point lists:
# html = html.gsub("<br /><li>", "<li>")
# html = html.gsub("<br /></ul>", "</ul>")
html = html.gsub("<br/><li>", "<li>")
html = html.gsub("<br/></ul>", "</ul>")

html = html.chomp("<br/>")

puts "resulting html:"
puts html

puts "wuwuwu".chomp("waw")
puts "wuwuwu".chomp("wu")
