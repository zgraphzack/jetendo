<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
<p>Purpose: A jQuery Slideshow with support for multiple layers of animation within each slide.</p>
  <p>Version: 0.1.000</p>
  <p>Language(s) used: Javascript</p>
   <p>Project Home Page: <a href="https://www.jetendo.com/z/admin/manual/view/9.2.4/jquery-parallax-slider.html">https://www.jetendo.com/z/admin/manual/view/9.2.4/jquery-parallax-slider.html</a></p>
  
   <p>GitHub Home Page: <a href="https://github.com/jetendo/jquery-parallax-slider" target="_blank">https://github.com/jetendo/jquery-parallax-slider</a></p>
  <h2>Outline</h2>
  <ul>
  <li><a href="##about">About</a></li>
  </ul>

<h2 id="about">About</h2>
<p>This plug-in allows you to build HTML 5 compatible slideshows and it has the following unique features:</p>
<ul><li>Independently animated layers within a slide</li>
<li>Customizable slide transitions including horizontal, vertical and crossfade</li>
<li>Responsive resizing.  A fixed width is set on the center slide content, but the background(s) of the slides will stretch to fill the width of the page.</li>
<li>Background elements can be animated in a loop at different speeds to create a sense of 3d depth using 2d images (<a href="http://en.wikipedia.org/wiki/Parallax_scrolling" title="Read more about Parallax Scrolling on Wikipedia" target="_blank">parallax scrolling</a>). Backgrounds can animate horizontally, vertically or diagonally with the built-in options.</li>
<li>Multiple slideshows on the same page</li>
<li>Easy to configure deferred loading of images and background images</li>
<li>High performance - only the currently visible slides are processed.</li>
</ul>
<p>This plug-in has many options to let you customize the animation when a slide begins and ends for all the elements within it as well as the slide itself. You can add a delay before an animation begins and change its duration.  You can change the animation to use any valid jquery easing name such as swing or linear.  If you combine this plugin with the <a href="https://github.com/gdsmith/jquery.easing" target="_blank">jquery easing plugin</a> in your project, you'll have access to many more easing options.</p>
<p>This plug-in has support for animating the following CSS: (background-position) or (left, top and opacity). If you need to animate something else, you can add your own options.slideBeginCallback(slideObj) and options.slideEndCallback(slideObj) callback functions to specify the other animations to perform.</p>
<p>This plugin was tested on all modern browsers IE7+, Chrome, Firefox, Safari, Opera and it also works on mobile tablets with good performance.</p>
<p>There isn't support for thumbnail / button navigation yet other then next/previous buttons.</p>
<p>More detailed documentation will be forthcoming.  This plugin has been tested with Jquery 1.8. It may work with other versions.</p>

<h2><a href="/manual/view/current/2.4.1/jquery-parallax-slider-examples.html" class="zNoContentTransition">View demo examples</a></h2>




<h2>License</h2>
<p>Copyright &copy; #year(now())# Far Beyond Code LLC.</p>

<p>jquery-parallax-slider is Open Source under the MIT license<br />
  <a href="http://www.opensource.org/licenses/mit-license.php" target="_blank">http://www.opensource.org/licenses/mit-license.php</a></p>

</cffunction>
</cfoutput>
</cfcomponent>