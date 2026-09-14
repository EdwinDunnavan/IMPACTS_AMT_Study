% pdf_print.m
function pdf_print(string,format)

set(gcf,'units','inches')
screenpos = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenpos(3:4)],'PaperSize',screenpos(3:4))

print('-vector',string,'-r400',format)

end