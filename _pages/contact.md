---
title: "Contact"
permalink: "/contact.html"
---

<form action="https://formspree.io/{{site.email}}" method="POST">    
<p class="mb-4">{{ site.data.i18n.fr.contact_intro }}</p>
<div class="form-group row">
<div class="col-md-6">
<input class="form-control" type="text" name="name" placeholder="{{ site.data.i18n.fr.contact_name }}" required>
</div>
<div class="col-md-6">
<input class="form-control" type="email" name="_replyto" placeholder="{{ site.data.i18n.fr.contact_email }}" required>
</div>
</div>
<textarea rows="8" class="form-control mb-3" name="message" placeholder="{{ site.data.i18n.fr.contact_message }}" required></textarea>    
<input class="btn btn-success" type="submit" value="{{ site.data.i18n.fr.contact_send }}">
</form>