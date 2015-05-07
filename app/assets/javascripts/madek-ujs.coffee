# Here wo do everything that does "progressive enhancement".
# It is always loaded right before the end of <body>, so we can
# directly manipulate the DOM!

# for now, we only need to set a class on the root so the styles are correct:
document.getElementsByTagName('html')[0].classList.add('has-js')
