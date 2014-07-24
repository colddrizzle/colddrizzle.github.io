---
layout: page
title: Hello World!
tagline: Supporting tagline
---
{% include JB/setup %}

#### 索引
<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
catagories_list:
<ul>
        {% assign categories_list = site.categories %}  
        {% include JB/categories_list %}
</ul>
pages:
<ul>
    {% assign pages_list = site.pages %}  
    {% include JB/pages_list %}
</ul>
posts_collate:
    {% assign posts_collate = site.posts %}
Tag list:
<ul>
  	  {% assign tags_list = site.tags %}  
  	  {% include JB/tags_list %}
</ul>
