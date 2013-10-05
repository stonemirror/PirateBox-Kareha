use strict;

BEGIN { require 'wakautils.pl' }

#
# Interface strings
#

use constant S_HOME => 'Home';										# Forwards to home page
use constant S_RETURN => 'Return';									# Returns to image board
use constant S_POSTING => 'Reply mode';								# Prints message in red bar atop the reply screen

use constant S_NAME => 'Name';										# Describes name field
use constant S_EMAIL => 'Link';										# Describes e-mail field
use constant S_SUBJECT => 'Subject';								# Describes subject field
use constant S_SUBMIT => 'Submit';									# Describes submit button
use constant S_COMMENT => 'Comment';								# Describes comment field
use constant S_UPLOADFILE => 'File';								# Describes file field
use constant S_CAPTCHA => 'Verification';							# Describes captcha field
use constant S_DELPASS => 'Password';								# Describes password field
use constant S_DELEXPL => '(for post and file deletion)';			# Prints explanation for password box (to the right)

use constant S_THUMB => 'Thumbnail displayed, click image for full size.';	# Prints instructions for viewing real source
use constant S_HIDDEN => 'Thumbnail hidden, click filename for the full image.';	# Prints instructions for viewing hidden image reply
use constant S_NOTHUMB => 'No<br />thumbnail';								# Printed when there's no thumbnail
use constant S_PICNAME => 'File: ';											# Prints text before upload name/link
use constant S_REPLY => 'Reply';											# Prints text for reply link
use constant S_ABBR => '%d posts omitted. Click Reply to view.';			# Prints text to be shown when replies are hidden
use constant S_ABBRIMG => '%d posts and %d images omitted. Click Reply to view.';						# Prints text to be shown when replies and images are hidden
use constant S_ABBRTEXT => 'Comment too long. Click <a href="%s">here</a> to view the full text.';

use constant S_REPDEL => 'Delete Post ';							# Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => 'File Only';							# Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Password ';								# Prints text next to password field for deletion (left)
use constant S_DELETE => 'Delete';									# Defines deletion button's name

use constant S_PREV => 'Previous';									# Defines previous button
use constant S_FIRSTPG => 'Previous';								# Defines previous button
use constant S_NEXT => 'Next';										# Defines next button
use constant S_LASTPG => 'Next';									# Defines next button

use constant S_FRONT => 'Front page';								# Title of the front page in page list

#
# Error strings
#

use constant S_BADCAPTCHA => 'Wrong verification code entered.';			# Error message when the captcha is wrong
use constant S_UNJUST => 'Posting must be done through a POST request.';	# Error message on an unjust POST - prevents floodbots or ways not using POST method?
use constant S_NOTEXT => 'No text entered.';								# Error message for no text entered in to title/comment
use constant S_NOTITLE => 'No title entered.';								# Error message for no title entered
use constant S_NOTALLOWED => 'Posting not allowed.';						# Error message when the posting type is forbidden for non-admins
use constant S_TOOLONG => 'The %s field is too long, by %d characters.';	# Error message for too many characters in a given field
use constant S_UNUSUAL => 'Abnormal reply.';								# Error message for abnormal reply? (this is a mystery!)
use constant S_SPAM => 'Spammers are not welcome here!';					# Error message when detecting spam
use constant S_THREADCOLL => 'Somebody else tried to post a thread at the same time. Please try again.';		# If two people create threads during the same second
use constant S_NOTHREADERR => 'Thread specified does not exist.';			# Error message when a non-existant thread is accessed
use constant S_BADDELPASS => 'Password incorrect.';							# Error message for wrong password (when user tries to delete file)
use constant S_NOTWRITE => 'Cannot write to directory.';					# Error message when the script cannot write to the directory, the chmod (777) is wrong
use constant S_NOTASK => 'Script error; no valid task specified.';			# Error message when calling the script incorrectly
use constant S_NOLOG => 'Couldn\'t write to log.txt.';						# Error message when log.txt is not writeable or similar
use constant S_TOOBIG => 'The file you tried to upload is too large.';		# Error message when the image file is larger than MAX_KB
use constant S_EMPTY => 'The file you tried to upload is empty.';			# Error message when the image file is 0 bytes
use constant S_BADFORMAT => 'File format not allowed.';						# Error message when the file is not in a supported format.
use constant S_DUPE => 'This file has already been posted <a href="%s">here</a>.';	# Error message when an md5 checksum already exists.
use constant S_DUPENAME => 'A file with the same name already exists.';		# Error message when an filename already exists.
use constant S_THREADCLOSED => 'This thread is closed.';					# Error message when posting in a legen^H^H^H^H^H closed thread
use constant S_SPAMTRAP => 'Leave empty (spam trap): ';

#
# Templates
#

# Header
use constant NORMAL_HEAD_INCLUDE => q{

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" />
		<title><if $title><var $title> - </if>PirateBox Forum</title>
		<link rel="shortcut icon" href="<const expand_filename(FAVICON)>" />
		<link rel="stylesheet" type="text/css" href="<const expand_filename(DEFAULT_STYLE)>" />
		<script type="text/javascript" src="/jquery.min.js"></script>
		<script type="text/javascript" src="/scripts.js"></script>
		<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
		<script type="text/javascript" src="<const expand_filename(JS_FILE)>"></script>
		<script type="text/javascript">require_script_version("3.a");</script>
	</head>

	<if $thread>
		<body class="replypage">
	</if>
	<if !$thread>
		<body class="mainpage">
	</if>

	}.include(INCLUDE_DIR."header.html").q{

};

# Footer
use constant NORMAL_FOOT_INCLUDE => include(INCLUDE_DIR."footer.html").q{

		</body>
	</html>

};

# Main Page
use constant MAIN_PAGE_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

	<div class="container">
		<if ALLOW_TEXT_THREADS or ALLOW_IMAGE_THREADS>
			<div id="post-area">
				<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
					<input type="hidden" name="task" value="post" />
					<if FORCED_ANON>
						<input type="hidden" name="field_a" />
					</if>
					<div id="post-form">
						<div class="card">
							<fieldset>
								<legend>Forum</legend>
								<if !FORCED_ANON>
									<label for="postform-name"><const S_NAME></label><input id="postform-name" type="text" name="field_a" placeholder="Name (will be Anonymous if empty)" />
								</if>
								<label for="post-form-link"><const S_EMAIL></label><input id="post-form-link" type="text" name="field_b" placeholder="anon@ymous.com" />
								<label for="post-form-subject"><const S_SUBJECT></label><input id="post-form-subject" type="text" name="title" placeholder="Subject" />
								<label for="post-form-comment"><const S_COMMENT></label><textarea id="post-form-comment" name="comment" rows="4" placeholder="Comment"></textarea>
								<if ALLOW_IMAGE_THREADS>
								<div id="post-form-upload">
									<label for="post-form-file"><const S_UPLOADFILE></label><input id="post-form-file" type="file" name="file" />
								</div>
								</if>
								<if ENABLE_CAPTCHA>
									<label for="post-form-captcha"><const S_CAPTCHA></label><input id="post-form-captcha" type="text" name="captcha" size="10" /><img alt="" src="<var expand_filename('captcha.pl')>" />
								</if>
								<label for="post-form-password">Password</label><input id="post-form-password" type="password" name="password" placeholder="Password (for post deletion)" />
								<input id="post-form-submit" class="button" type="submit" value="<const S_SUBMIT>" />
								<!--<if SPAM_TRAP>
									<label><const S_SPAMTRAP></label><input type="text" name="name" size="10" autocomplete="off" /><input type="text" name="link" size="10" autocomplete="off" />
								</if>-->
							</fieldset>
						</div>
					</div>
					<div id="post-rules"><div class="card">}.include(INCLUDE_DIR."rules.html").q{</div></div>
				</form>
			</div>
			<script type="text/javascript">set_new_inputs("postform")</script>
		</if>
		<form id="delform" action="<var $self>" method="post">
			<loop $threads>
				<div class="thread card">
					<loop $posts>
						<var $text>
						<if $abbreviated>
							<div class="abbrev">
								<var sprintf(S_ABBRTEXT,"$self/$thread/$num","$self/$thread/")>
							</div>
						</if>
						<if $omit and $num==1>
							<span class="omittedposts">
								<if $omitimages>
									<var sprintf S_ABBRIMG,$omit,$omitimages>
								</if>
								<if !$omitimages>
									<var sprintf S_ABBR,$omit>
								</if>
							</span>
						</if>
					</loop>
				</div>
			</loop>

			<div class="card">
				<table class="pages" border="1">
					<tbody>
						<tr>
							<td>
								<if $prevpage>
									<form method="get" action="<var $prevpage>">
										<input value="<const S_PREV>" type="submit" />
									</form>
								</if>
								<if !$prevpage>
									<const S_FIRSTPG>
								</if>
							</td>
							<td>
								<loop $pages>
									<if $page ne $current>
										[<a href="<var $filename>"><var $page></a>]
									</if>
									<if $page eq $current>
										[<var $page>]
									</if>
								</loop>
							</td>
							<td>
								<if $nextpage>
									<form method="get" action="<var $nextpage>">
										<input value="<const S_NEXT>" type="submit" />
									</form>
								</if>
								<if !$nextpage>
									<const S_LASTPG>
								</if>
							</td>
						</tr>
					</tbody>
				</table>
				<div class="userdelete">
					<input type="hidden" name="task" value="delete" />
					<const S_REPDEL>[<input type="checkbox" name="fileonly" value="on" /><const S_DELPICONLY>]
					<const S_DELKEY><input type="password" name="password" size="8" />
					<input value="<const S_DELETE>" class="button" type="submit" />
				</div>
			</div>
		</form>

		<script type="text/javascript">set_delpass("delform")</script>
	</div>

}.NORMAL_FOOT_INCLUDE,KEEP_MAINPAGE_NEWLINES);

# Reply Page
use constant THREAD_HEAD_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
	<div class="theader">
		<const S_POSTING>
	</div>

	<div class="container">
		<if ALLOW_TEXT_REPLIES or ALLOW_IMAGE_REPLIES>
			<div class="postarea card">
				<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
					<input type="hidden" name="task" value="post" />
					<input type="hidden" name="thread" value="<var $thread>" />
					<if FORCED_ANON>
						<input type="hidden" name="field_a" />
					</if>
					<table>
						<tbody>
							<if !FORCED_ANON>
								<tr>
									<td class="postblock">
										<const S_NAME>
									</td>
									<td>
										<input type="text" name="field_a" size="28" />
									</td>
								</tr>
							</if>
							<tr>
								<td class="postblock">
									<const S_EMAIL>
								</td>
								<td>
									<input type="text" name="field_b" size="28" />
								</td>
							</tr>
							<tr>
								<td class="postblock">
									<const S_SUBJECT>
								</td>
								<td>
									<input type="text" name="title" size="35" />
									<input type="submit" class="button" value="<const S_SUBMIT>" />
								</td>
							</tr>
							<tr>
								<td class="postblock">
									<const S_COMMENT>
								</td>
								<td>
									<textarea name="comment" cols="48" rows="4"></textarea>
								</td>
							</tr>
							<if ALLOW_IMAGE_REPLIES>
								<tr>
									<td class="postblock">
										<const S_UPLOADFILE>
									</td>
									<td>
										<input type="file" name="file" size="35" />
									</td>
								</tr>
							</if>
							<if ENABLE_CAPTCHA>
								<tr>
									<td class="postblock">
										<const S_CAPTCHA>
									</td>
									<td>
										<input type="text" name="captcha" size="10" />
										<img alt="" src="<var expand_filename('captcha.pl')>?dummy=<var $size>" />
									</td>
								</tr>
							</if>
							<tr>
								<td class="postblock">
									<const S_DELPASS>
								</td>
								<td>
									<input type="password" name="password" size="8" />
									<const S_DELEXPL>
								</td>
							</tr>
							<if SPAM_TRAP>
								<tr style="display:none">
									<td class="postblock">
										<const S_SPAMTRAP>
									</td>
									<td>
										<input type="text" name="name" size="10" autocomplete="off" />
										<input type="text" name="link" size="10" autocomplete="off" />
									</td>
								</tr>
							</if>
							<tr>
								<td colspan="2">
									<div class="rules">}.include(INCLUDE_DIR."rules.html").q{</div>
								</td>
							</tr>
						</tbody>
					</table>
				</form>
			</div>
			<script type="text/javascript">set_new_inputs("postform")</script>
		</if>

		
	</div>
	<form id="delform" action="<var $self>" method="post">

});

# Delete Posts
use constant THREAD_FOOT_TEMPLATE => compile_template(q{

	<br clear="left" /><hr />

	<table class="userdelete"><tbody><tr><td>
	<input type="hidden" name="task" value="delete" />
	<const S_REPDEL>[<label><input type="checkbox" name="fileonly" value="on" /><const S_DELPICONLY></label>]<br />
	<const S_DELKEY><input type="password" name="password" size="8" />
	<input value="<const S_DELETE>" type="submit" /></td></tr></tbody></table>
	</form>
	<script type="text/javascript">set_delpass("delform")</script>

}.NORMAL_FOOT_INCLUDE);

# Posts and Replies
use constant REPLY_TEMPLATE => compile_template( q{

	<if $num==1>
		<if $image>
			<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_filename(clean_path($image))>"><var get_filename($image)></a>
			-(<em><var $size> B, <var $width>x<var $height></em>)</span>
			<span class="thumbnailmsg"><const S_THUMB></span><br />

			<if $thumbnail>
				<a target="_blank" href="<var expand_filename(clean_path($image))>">
				<img src="<var expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" class="thumb" /></a>
			</if>
			<if !$thumbnail>
				<div class="nothumb"><a target="_blank" href="<var expand_filename(clean_path($image))>"><const S_NOTHUMB></a></div>
			</if>
		</if>

		<div class="post">
			<a name="<var $num>"></a>
			<div class="post-head">
				<input type="checkbox" name="delete" value="<var $thread>,<var $num>" />
				<span class="post-subject"><var $title></span>
				<if $link>
					<span class="post-user"><a href="<var $link>"><var $name></a></span>
					<if $trip>
						<span class="postertrip">
							<a href="<var $link>">
								<if !$capped>
									<var $trip>
								</if>
								<if $capped>
									<var $capped>
								</if>
							</a>
						</span>
					</if>
				</if>
				<if !$link>
					<span class="post-user"><var $name></span>
					<if $trip>
						<span class="postertrip">
							<if !$capped>
								<var $trip>
							</if>
							<if $capped>
								<var $capped>
							</if>
						</span>
					</if>
				</if>
				<span class="post-data"><var $date></var></span>
				<span class="post-number"><a href="javascript:w_insert('&gt;&gt;<var $num>','<var $self>/<var $thread>/')">No.<var $num></a></span>
				<span class="post-reply">[<a href="<var $self>/<var $thread>/" id="reply<var $thread>"><const S_REPLY></a>]</span>
			</div>
			<div class="post-content">
				<blockquote>
					<var $comment>
				</blockquote>
			</div>
		</div>
	</if>
	<if $num!=1>
		<div class="reply" id="reply<var $num>">
			<a name="<var $num>"></a>
			<div class="post-head">
				<input type="checkbox" name="delete" value="<var $thread>,<var $num>" />
				<span class="post-subject"><var $title></span>
				<if $link>
					<span class="post-user"><a href="<var $link>"><var $name></a></span>
					<if $trip>
						<span class="postertrip">
							<a href="<var $link>">
								<if !$capped>
									<var $trip>
								</if>
								<if $capped>
									<var $capped>
								</if>
							</a>
						</span>
					</if>
				</if>
				<if !$link>
					<span class="post-user"><var $name></span>
					<if $trip>
						<span class="postertrip">
							<if !$capped>
								<var $trip>
							</if>
							<if $capped>
								<var $capped>
							</if>
						</span>
					</if>
				</if>
				<span class="post-data"><var $date></var></span>
				<span class="post-number"><a href="javascript:w_insert('&gt;&gt;<var $num>','<var $self>/<var $thread>/')">No.<var $num></a></span> 
			</div>
			<if $image>
				<br />
				<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_filename(clean_path($image))>"><var get_filename($image)></a>
				-(<em><var $size> B, <var $width>x<var $height></em>)</span>
				<span class="thumbnailmsg"><const S_THUMB></span><br />

				<if $thumbnail>
					<a target="_blank" href="<var expand_filename(clean_path($image))>">
					<img src="<var expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" class="thumb" /></a>
				</if>
				<if !$thumbnail>
					<div class="nothumb"><a target="_blank" href="<var expand_filename(clean_path($image))>"><const S_NOTHUMB></a></div>
				</if>
			</if>
			<div class="post-content">
				<blockquote>
					<var $comment>
				</blockquote>
			</div>
		</div>
	</if>

});

use constant DELETED_TEMPLATE => compile_template( q{
});

use constant BACKLOG_PAGE_TEMPLATE => compile_template( NORMAL_HEAD_INCLUDE.q{
}.NORMAL_FOOT_INCLUDE);

use constant RSS_TEMPLATE => compile_template( q{
});

use constant ERROR_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

	<h1 style="text-align: center">
		<var $error><br /><br />
		<a href="<var escamp($ENV{HTTP_REFERER})>"><const S_RETURN></a><br /><br />
	</h1>

}.NORMAL_FOOT_INCLUDE);

sub get_filename($) { my $path=shift; $path=~m!([^/]+)$!; clean_string($1) }

1;
