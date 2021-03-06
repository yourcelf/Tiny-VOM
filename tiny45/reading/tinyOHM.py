from Tkinter import *
import serial

WINDOW = 600
eps = 0.1
saveflag = 0
filter = 0.0

def idle(parent,canvas):
   global saveflag, filter, eps
   #
   # idle routine
   #
   ser.flush()

   low = ord(ser.read())
   high = ord(ser.read())
   value = 256*high + low
   filter = (1-eps)*filter + eps*value
   
   x = int(.2*WINDOW + (.9-.2)*WINDOW*filter/1024.0)

   canvas.itemconfigure("text",text="%.1f"%filter)
   canvas.coords('rect1',.2*WINDOW,.05*WINDOW,x,.2*WINDOW)
   canvas.coords('rect2',x,.05*WINDOW,.9*WINDOW,.2*WINDOW)
   canvas.update()
   parent.after_idle(idle,parent,canvas)

#
# open serial port
#
ser = serial.Serial('/dev/ttyS0',9600)
ser.setDTR()
#
# start plotting
#
root = Tk()
root.title('tinyOHM (q to exit)')
root.bind('q','exit')
canvas = Canvas(root, width=WINDOW, height=.25*WINDOW, background='white')
canvas.create_text(.1*WINDOW,.125*WINDOW,text=".33",font=("Helvetica", 24),tags="text",fill="#ff0066")
canvas.create_rectangle(.2*WINDOW,.05*WINDOW,.3*WINDOW,.2*WINDOW, tags='rect1', fill='#ff0066')
canvas.create_rectangle(.3*WINDOW,.05*WINDOW,.9*WINDOW,.2*WINDOW, tags='rect2', fill='#999999')
canvas.pack()
root.after(100,idle,root,canvas)
root.mainloop()
