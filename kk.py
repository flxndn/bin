import sectxt

sec = sectxt.Section()

t = """* Prueba
	- [[http://www.google.es|hola]]"""

sec.parseText(t)

l=sec.toHTML(extra_divs=False)
ll=l.split("\n")
del ll[0]
print "\n".join(ll)
