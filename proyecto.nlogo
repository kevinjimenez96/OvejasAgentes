breed [ovejas oveja]
breed [perros perro]
breed [trees tree]

;;*************************
;; DEFINICIÓN DE VARIABLES:
;;*************************

globals ;; Para definir las variables globales.
[
  r_s ;; Distancia minima de las ovejas al pastor
  r_a ;; Distancia minima de interaccion de agentes
  h   ;; Fuerza relativa de direccion contraria = 0.5
  c   ;; Fuerza relativa de atraccion = 1.05
  p_a ;; Fuerza relativa de repulsion de otros agentes = 2
  p_s ;; Fuerza relativa de repulsion del pastor = 1
  err ;; Ruido
  p_d ;; distancia del perro al gcm
  gcm ;; Global center of mass
  completed
  target
  pared-cerca
]

turtles-own ;; Para definir los atributos de las tortugas.
[

]

patches-own ;; Para definir los atributos de las parcelas.
[

]

links-own ;; Para definir los atributos de los links o conexiones.
[

]

;;********************
;; variables de breeds
;;********************

ovejas-own[
  cm ;; Center of mass: axis
  c_i

  r-s-v
  r-a-v
  l-c-m
  perro-cerca
  vecina-cerca

]

perros-own
[
  oveja-lejos
]
;;**************************************
;; INICIALIZACIÓN DE VARIABLES GLOBALES:
;;**************************************

to init-globals ;; Para darle valor inicial a las variables globales.
  set r_s 65
  set r_a 2
  set h 0.5
  set c 1.05
  set p_a 2
  set p_s 1
  set p_d (r_a * sqrt (num-sheeps))
  set completed false
  set target list 199 199
  set gcm list 0 0
end

;;**********************
;; FUNCIONES PRINCIPALES
;;**********************

to setup ;; Para inicializar la simulación.
  ca           ;; Equivale a clear-ticks + clear-turtles + clear-patches +
               ;; clear-drawing + clear-all-plots + clear-output.

  init-globals ;; Para inicializar variables globales.

  draw-walls
  ask patches
  [
    ;;init-zona-meta
  ]
  create-perros 1
  [
    init-perros
    set oveja-lejos true
  ]

  create-ovejas num-sheeps
  [
    init-ovejas
    set size 3
  ]

  crt 1
  [
    init-turtle-pastor
  ]

  crt 1
  [
    init-poste-uno
  ]

  crt 1
  [
    init-poste-dos
  ]

  crt 1
  [
    init-poste-tres
  ]

  create-tgts


  reset-ticks  ;; Para inicializar el contador de ticks.
end

to create-tgts
  ask n-of num-trees patches[set pcolor red]
  ;create-trees num-trees [
    ;setxy random-xcor random-ycor
    ;set size 3
    ;set shape "tree"
    ;set color red
  ;]
end

to go ;; Para ejecutar la simulación.
  set gcm centro-masa-ovejas ovejas
  ask ovejas [
    ups-pared
    detectar-arboles
    manejar-esquinas
    huir-de-perro
    alejarse-de-ovejas-vecinas
    ifelse pared-cerca[
      if perro-cerca[
        facexy first r-s-v last r-s-v
        fd p_s
        set l-c-m (centro-masa-ovejas ovejas in-radius k)
        facexy first l-c-m last l-c-m
        fd c
      ]
      if vecina-cerca [
        facexy first r-a-v last r-a-v
        fd p_a
      ]
    ]
    [
      lt random-float 360
    ]
  ]
  ask perros [
    ups-pared
    detectar-arboles
    revisar-rebano
    ifelse oveja-lejos
    [
      let p-arreo report-punto-recoleccion
      facexy first p-arreo last p-arreo
      fd 1
    ]
    [
      let p-arreo report-punto-arreo
      facexy first p-arreo last p-arreo
      fd 1
    ]

  ]
  revisar-corral

  if completed = true
  [stop]
  tick
  actualizar-salidas


end


;;*******************************
;; Otras funciones globales:
;;*******************************

to actualizar-salidas ;; Para actualizar todas las salidas del modelo.
end

to-report vector-add [v1 v2]
  report (list (first v1 + first v2) (last v1 + last v2))
end

to-report vector-sub [v1 v2]
  report (list (first v1 - first v2) (last v1 - last v2))
end

to-report vector-mul [v1 v2]
  report (first v1 * first v2) + (last v1 * last v2)
end

to-report vector-sca-mul [v1 v2]
  report (list (first v1 * v2) (last v1 * v2))
end

to-report vector-mag [v1]
  report sqrt(first v1 ^ 2 + last v1 ^ 2)
end

to-report vector-uni [v1]
  report vector-sca-mul v1 (1 / (vector-mag v1))
end
;;**********************
;; Funciones de turtles:
;;**********************

to init-turtle-pastor ;; Para inicializar una tortuga a la vez.
  set size 7
  set color green
  set xcor 200
  set ycor 200
end

to init-poste-uno ;; Para inicializar una tortuga a la vez.
  set size 7
  set color yellow
  set xcor 0
  set ycor 200
end

to init-poste-dos ;; Para inicializar una tortuga a la vez.
  set size 7
  set color cyan
  set xcor 0
  set ycor 0
end

to init-poste-tres ;; Para inicializar una tortuga a la vez.
  set size 7
  set color black
  set xcor 200
  set ycor 0
end

to t-comportamiento-turtle ;; Se debería cambiar el nombre para que represente algo signficativo en la simulación.

end

;;**********************
;; Funciones de patches:
;;**********************

to init-patch ;; Para inicializar una parcela a la vez.

end

to init-zona-meta
  if pxcor > 160 and pycor > 160
  [
    set pcolor red
  ]
end

to p-comportamiento-patch ;; Cambiar por nombre significativo de comportamiento de patch

end

;;********************
;; Funciones de links:
;;********************

to init-link ;; Para inicializar un link o conexión a la vez.

end

to l-comportamiento-link ;; Cambiar por nombre significativo de comportamiento de link

end

;;*********************
;; Funciones de breeds:
;;*********************
to init-ovejas
  set xcor random 50 + 50
  set ycor random 50 + 50
  set color white
  set r-a-v list 0 0
end

to init-perros
  set size 7
  set color blue
  set xcor (random 50) + 150
  set ycor (random 20)
end


to huir-de-perro
  ifelse distance turtle 0 < r_s
  [
    let posOveja (list xcor ycor)
    let posPerro (list ([xcor] of turtle 0) ([ycor] of turtle 0))
    set r-s-v vector-add posOveja (vector-sub posOveja posPerro)
    set perro-cerca true
  ]
  [
    set perro-cerca false
  ]
end

to alejarse-de-ovejas-vecinas
  ifelse count ovejas in-radius r-a > 1
  [
    let vecinas list 0 0
    let posOveja (list xcor ycor)
    ask ovejas in-radius r-a
    [
      let posNewVecina (list xcor ycor)
      let newVecina vector-sub posOveja posNewVecina
      set newVecina vector-sca-mul newVecina (vector-mag newVecina)
      set vecinas (vector-add vecinas newVecina)
    ]
    set r-a-v vector-add posOveja vecinas
    set vecina-cerca true
  ]
  [
    set vecina-cerca false
  ]
end

to ups-pared
  let frente patch-ahead 1
  ifelse frente != NOBODY[
    ifelse [pcolor] of frente = blue
  [
    set pared-cerca false
  ]
  [
    set pared-cerca true
  ]
  ][
    set pared-cerca false
  ]

end

to-report centro-masa-ovejas [grupo-ovejas]
  let vecinas list  (mean [xcor] of grupo-ovejas) (mean [ycor] of grupo-ovejas)
  report vecinas
end

to-report report-punto-arreo
  let target-to-gcm vector-sub gcm target
  let p_arreo vector-sca-mul (vector-uni target-to-gcm) p_d
  report vector-add p_arreo gcm
end

to-report report-punto-recoleccion
  let ovejaMasLejana max-one-of ovejas [distancexy first gcm last gcm]
  let pos list ([xcor] of ovejaMasLejana) ([ycor] of ovejaMasLejana)
  let gcm-to-oveja vector-sub pos gcm
  set gcm-to-oveja vector-uni gcm-to-oveja
  let p-recoleccion vector-sca-mul gcm-to-oveja r_a
  report vector-add pos p-recoleccion
end

to revisar-rebano
  ;;let radio-revision r-a * num-sheeps ^ 0.66
  let ovejaMasLejana max-one-of ovejas [distancexy first gcm last gcm]
  ;;let dist-oveja distance ovejaMasLejana ;;necesito sacar la distancia de la oveja mas lejos al gcm
  let dist-oveja 0
  ask ovejaMasLejana [
    set dist-oveja distancexy first gcm last gcm
  ]
  ifelse dist-oveja > radio-revision
  [
    set oveja-lejos false
  ]
  [
    set oveja-lejos true
  ]

end

to revisar-corral
  ask turtles with [color = green]
  [
    let near-sheep turtles in-radius 40
    if count near-sheep >= num-sheeps - 40
    [
      set completed true
    ]
  ]

end


to draw-walls

  ask patches with [abs pxcor > 170 and abs pycor = 158 ]
    [ set pcolor blue ]
  ask patches with [abs pxcor > 170 and abs pycor = 159 ]
    [ set pcolor blue ]

  ask patches with [abs pxcor = 158 and abs pycor > 170 ]
    [ set pcolor blue ]
  ask patches with [abs pxcor = 159 and abs pycor > 170 ]
    [ set pcolor blue ]

end

to manejar-esquinas
  ask turtles with [color = yellow]
  [
    let near-sheep turtles in-radius 15
    if count near-sheep > num-sheeps - 50
    [
      ask turtle 0 [setxy 0 200]
    ]
  ]

  ask turtles with [color = black]
  [
    let near-sheep turtles in-radius 15
    if count near-sheep > num-sheeps - 50
    [
      ask turtle 0 [setxy 200 0]
    ]
  ]

  ask turtles with [color = cyan]
  [
    let near-sheep turtles in-radius 15
    if count near-sheep > num-sheeps - 50
    [
      ask turtle 0 [setxy 0 0]
    ]
  ]

end

to detectar-arboles
  let frente patch-ahead 2
  ifelse frente != NOBODY[
    ifelse [pcolor] of frente = red
  [
    set pared-cerca false
  ]
  [
    set pared-cerca true
  ]
  ][
    set pared-cerca false
  ]
end


;; Controles

to izq
  ask turtle 0[
    facexy 0 ycor
  ]
end

to der
  ask turtle 0[
    facexy 200 ycor
  ]
end

to up
  ask turtle 0[
    facexy xcor 200
  ]
end

to down
  ask turtle 0[
    facexy xcor 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
253
11
693
452
-1
-1
2.15
1
10
1
1
1
0
0
0
1
0
200
0
200
0
0
1
ticks
30.0

BUTTON
27
52
90
85
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
26
11
89
44
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
115
172
148
k
k
0
50
18.0
1
1
NIL
HORIZONTAL

SLIDER
0
160
172
193
r-s
r-s
0
100
60.0
5
1
NIL
HORIZONTAL

SLIDER
0
207
172
240
r-a
r-a
0
8
2.0
2
1
NIL
HORIZONTAL

SLIDER
0
264
172
297
num-trees
num-trees
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
0
339
172
372
num-sheeps
num-sheeps
1
200
52.0
1
1
NIL
HORIZONTAL

BUTTON
8
415
71
448
NIL
izq
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
76
415
139
448
NIL
der
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
75
379
138
412
NIL
up
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
8
378
71
411
NIL
down
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

MONITOR
904
102
964
147
Distance
[oveja-lejos] of perro 0
17
1
11

SLIDER
864
292
1036
325
radio-revision
radio-revision
0
100
80.0
1
1
NIL
HORIZONTAL

MONITOR
823
206
880
251
READY
completed
17
1
11

@#$#@#$#@
## ¿DE QUÉ SE TRATA?

(una descripción general de lo que el modelo trata de modelar o explicar)

## ¿CÓMO FUNCIONA?

(qué reglas usan los agentes para orginar el funcionamiento del modelo)

## ¿CÓMO USARLO?

(cómo usar el modelo, incluye una descripción de cada uno de los controles en la interfaz)

## ¿QUÉ TOMAR EN CUENTA?

(cosas que debe tener en cuenta el usuario al ejecutar el modelo)

## ¿QUÉ PROBAR?

(sugerencias para el usuario sobre qué pruebas realizar (mover los "sliders", los "switches", etc.) con el modelo)

## EXTENDIENDO EL MODELO

(sugerencias sobre cómo realizar adiciones o cambios en el código del modelo para hacerlo más complejo, detallado, preciso, etc.)

## CARACTERÍSTICAS NETLOGO

(características interesantes o inusuales de NetLogo que usa el modelo, particularmente de código; o cómo se logra implementar características inexistentes)

## MODELOS RELACIONADOS 

(otros modelos de interés disponibles en la Librería de Modelos de NetLogo o en otros repositorios de modelos)

## CRÉDITOS AND REFERENCIAS

(referencia a un URL en Internet si es que el modelo tiene una, así como los créditos necesarios, citas y otros hipervínculos)

## ODD - ESPECIFICACIÓN DETALLADA DEL MODELO

## Título
(nombre del modelo)

## Autores
(nombre de los autores del modelo)

## Visión
## 1  Objetivos:
( 1.1  )
## 2  Entidades, variables de estado y escalas:
( 2.1 ) 
## 3  Visión del proceso y programación:
( 3.1  )

## Conceptos del diseño
## 4  Propiedades del modelo:
##  4.1  Básicas:
()
##  4.2  Emergentes:
()
##  4.3  Adaptabilidad:
()
##  4.4  Metas:
()
##  4.5  Aprendizaje:
()
##  4.6  Predictibilidad:
()
##  4.7  Sensibilidad:
()
##  4.8  Interacciones:
()
##  4.9  Estocasticidad:
()
##  4.10  Colectividades:
()
##  4.11  Salidas:
()
## Detalles
##  5  Inicialización:
()
##  6  Datos de entrada:
()
##  7  Submodelos:
()
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Experimento 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>completed? == true</exitCondition>
    <metric>count ticks</metric>
    <enumeratedValueSet variable="r-a">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="r-s">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sheeps">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-trees">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
