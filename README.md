# sce-fb-drv
Slow and horrible high level programmed framebuffer driver in sce. Idk abt licences, I give you full access to do anything you want with this source. I guess it should inherit sce's, but again, idk, sorry. Build scripts broken.
Things that can be done better(or to dos, project isn't halted):
 - macro to call function
 - less checks
 - better & correctly-placed test data (plane map, art, palette etc.)
 - write directly to vram instead of calling dma queue
 - could modify both planes for double the colors
   (explanation:
     if on the fg plane we set a pixel to transparent,
     that same pixel in the bg plane could be colored
     and that plane can use a different palette
   )
 - that's all I can think if, lmk if there's anything else in push requests, hopefully I'll check them.
 THANK YOU END OF FILE BYEEEE
