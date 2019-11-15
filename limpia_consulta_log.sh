#!/bin/bash

# Cuando se leen del log las consultas tienen escapados los retornos de línea y los tabuladores para que se vea bien los desescapamos

sed 's/\\r\\n/\n/g;s/\\n/\n/g;s/\\t/\t/g'
